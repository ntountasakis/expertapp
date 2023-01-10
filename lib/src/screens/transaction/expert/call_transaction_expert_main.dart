import 'package:expertapp/src/agora/agora_rtc_engine_wrapper.dart';
import 'package:expertapp/src/agora/agora_video_call.dart';
import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/expert_in_call_appbar.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CallTransactionExpertMain extends StatefulWidget {
  final String callTransactionId;
  final String currentUserId;
  final String callerUserId;

  CallTransactionExpertMain(
      {required this.callTransactionId,
      required this.currentUserId,
      required this.callerUserId});

  @override
  State<CallTransactionExpertMain> createState() =>
      _CallTransactionExpertMainState(new CallServerManager(
          currentUserId: currentUserId, otherUserId: callerUserId));
}

class _CallTransactionExpertMainState extends State<CallTransactionExpertMain> {
  final CallServerManager callServerManager;
  bool requestedExit = false;
  final RtcEngineWrapper engineWrapper = RtcEngineWrapper();
  AgoraVideoCall? videoCall;

  _CallTransactionExpertMainState(this.callServerManager);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callServerManager.joinCall(
          context: context, callTransactionId: widget.callTransactionId);
    });
  }

  Widget buildCallView(BuildContext context, CallServerModel model) {
    if (model.callConnectionState == CallServerConnectionState.DISCONNECTED) {
      onServerDisconnect(model);
      return SizedBox();
    }
    if (model.agoraCredentials == null ||
        model.callCounterpartyConnectionState ==
            CallServerCounterpartyConnectionState.DISCONNECTED) {
      return CircularProgressIndicator();
    } else if (videoCall == null) {
      final agoraChannelName = model.agoraCredentials!.channelName;
      final agoraToken = model.agoraCredentials!.token;
      final agoraUid = model.agoraCredentials!.uid;
      videoCall = AgoraVideoCall(
        agoraChannelName: agoraChannelName,
        agoraToken: agoraToken,
        agoraUid: agoraUid,
        onChatButtonTap: onChatButtonTap,
        onEndCallButtonTap: onEndCallTap,
        engineWrapper: engineWrapper,
      );
    }
    return videoCall!;
  }

  void onChatButtonTap() {
    context.pushNamed(Routes.CLIENT_CALL_CHAT_PAGE, params: {
      Routes.CALLER_UID_PARAM: widget.callerUserId,
      Routes.CALL_TRANSACTION_ID_PARAM: widget.callTransactionId,
    });
  }

  Future<void> onEndCallTap() async {
    await callServerManager.requestDisconnect();
  }

  void onServerDisconnect(CallServerModel model) {
    if (!requestedExit) {
      requestedExit = true;
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        if (videoCall != null) {
          await engineWrapper.teardown();
        }
        context.goNamed(Routes.CLIENT_SUMMARY_PAGE);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentWrapper<UserMetadata>?>(
        future: UserMetadata.get(widget.callerUserId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<UserMetadata>?> snapshot) {
          if (snapshot.hasData) {
            final callerUserMetadata = snapshot.data;
            return Consumer<CallServerModel>(builder: (context, model, child) {
              return Scaffold(
                appBar: ExpertInCallAppbar(callerUserMetadata!, model),
                body: buildCallView(context, model),
              );
            });
          }
          return Scaffold(body: CircularProgressIndicator());
        });
  }
}

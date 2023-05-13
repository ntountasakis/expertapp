import 'package:expertapp/src/agora/agora_video_call.dart';
import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_error_dialog.dart';
import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/appbars/expert_view/expert_in_call_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class ExpertViewCallMainPage extends StatefulWidget {
  final String callTransactionId;
  final String currentUserId;
  final String callerUserId;

  ExpertViewCallMainPage(
      {required this.callTransactionId,
      required this.currentUserId,
      required this.callerUserId});

  @override
  State<ExpertViewCallMainPage> createState() =>
      _ExpertViewCallMainPageState(new CallServerManager(
          currentUserId: currentUserId, otherUserId: callerUserId));
}

class _ExpertViewCallMainPageState extends State<ExpertViewCallMainPage> {
  final CallServerManager callServerManager;
  bool requestedExit = false;
  bool errorDialogShown = false;
  AgoraVideoCall? videoCall;

  _ExpertViewCallMainPageState(this.callServerManager);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callServerManager.joinCall(
          context: context, callTransactionId: widget.callTransactionId);
    });
  }

  Widget buildErrorView(BuildContext context, CallServerModel model) {
    if (!errorDialogShown) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showCallServerErrorDialog(context, model, onServerDisconnect);
        errorDialogShown = true;
      });
    }
    return SizedBox();
  }

  Widget buildCallView(BuildContext context, CallServerModel model) {
    if (model.callConnectionState == CallServerConnectionState.DISCONNECTED) {
      onServerDisconnect(model);
      return SizedBox();
    }
    if (model.callConnectionState == CallServerConnectionState.ERRORED) {
      return buildErrorView(context, model);
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
        onRemoteUserJoined: callServerManager.onRemoteUserJoined,
      );
    }
    return videoCall!;
  }

  void onChatButtonTap() {
    context.pushNamed(Routes.EV_CALL_CHAT_PAGE, pathParameters: {
      Routes.CALLER_UID_PARAM: widget.callerUserId,
      Routes.CALL_TRANSACTION_ID_PARAM: widget.callTransactionId,
    });
  }

  Future<void> onEndCallTap() async {
    await callServerManager.requestDisconnectFromServer();
  }

  void onServerDisconnect(CallServerModel model) {
    if (!requestedExit) {
      requestedExit = true;
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        context.goNamed(Routes.EV_CALL_SUMMARY_PAGE);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentWrapper<PublicUserInfo>?>(
        future: PublicUserInfo.get(widget.callerUserId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicUserInfo>?> snapshot) {
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

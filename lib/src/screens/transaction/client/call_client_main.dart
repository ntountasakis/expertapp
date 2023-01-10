import 'package:expertapp/src/agora/agora_rtc_engine_wrapper.dart';
import 'package:expertapp/src/agora/agora_video_call.dart';
import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/appbars/client_in_call_appbar.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:expertapp/src/screens/transaction/client/widgets/call_waiting_join.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:expertapp/src/util/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CallClientMain extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final AppLifecycle lifecycle;

  const CallClientMain(
      {required this.currentUserId,
      required this.otherUserId,
      required this.lifecycle});

  @override
  State<CallClientMain> createState() =>
      _CallClientMainState(new CallServerManager(
          currentUserId: currentUserId, otherUserId: otherUserId));
}

class _CallClientMainState extends State<CallClientMain> {
  final CallServerManager callServerManager;
  bool requestedExit = false;
  bool exiting = false;
  final RtcEngineWrapper engineWrapper = RtcEngineWrapper();
  AgoraVideoCall? videoCall;

  _CallClientMainState(this.callServerManager);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callServerManager.initiateCall(context);
    });
  }

  Widget buildVideoCallView(BuildContext context, CallServerModel model) {
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
    context.pushNamed(Routes.EXPERT_CALL_CHAT_PAGE,
        params: {Routes.EXPERT_ID_PARAM: widget.otherUserId});
  }

  Future<void> onEndCallTap() async {
    requestedExit = true;
    await callServerManager.requestDisconnect();
  }

  Future<void> onPaymentCancelled(
      BuildContext context, CallServerModel model) async {
    if (!requestedExit) {
      requestedExit = true;
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        await callServerManager.requestDisconnect();
      });
    }
  }

  void onServerDisconnect(CallServerModel model) {
    if (!exiting) {
      exiting = true;
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        if (videoCall != null) {
          await engineWrapper.teardown();
        }
        final counterpartyJoined = model.callCounterpartyConnectionState ==
            CallServerCounterpartyConnectionState.JOINED;
        if (counterpartyJoined) {
          context.goNamed(Routes.EXPERT_CALL_SUMMARY_PAGE,
              params: {Routes.CALLED_UID_PARAM: widget.otherUserId});
        } else {
          model.reset();
          context.goNamed(Routes.HOME);
        }
      });
    }
  }

  Widget buildAwaitingPaymentView(CallServerModel model) {
    final paymentPrompt =
        "We are requesting a hold on your card for the amount of ${formattedRate(model.callPaymentPromptModel.centsRequestedAuthorized)}. "
        "At the end of the call, we will charge your card for the actual amount of time you were connected to the expert. "
        "The call can last a maximum of ${CallSummaryUtil.callLengthFormat(Duration(seconds: model.secMaxCallLength))}. "
        "Once that time has elapsed, the call will automatically end.";
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              paymentPrompt,
              style: CallSummaryUtil.LIGHT_STYLE,
            ),
          ),
          SizedBox(height: 20),
          CallSummaryUtil.buildButton(model, "Authorize Payment Hold",
              (_) async {
            await model.callPaymentPromptModel.presentPaymentSheet();
          }),
        ],
      ),
    );
  }

  Widget buildCallView(BuildContext context, CallServerModel model,
      DocumentWrapper<UserMetadata> calledMetadata) {
    if (model.callConnectionState == CallServerConnectionState.DISCONNECTED) {
      onServerDisconnect(model);
      return SizedBox();
    }
    if (model.callPaymentPromptModel.paymentState == PaymentState.NA) {
      return SizedBox();
    }
    if (model.callPaymentPromptModel.paymentState ==
        PaymentState.PAYMENT_CANCELLED) {
      onPaymentCancelled(context, model);
      return SizedBox();
    }
    if (model.callPaymentPromptModel.paymentState !=
        PaymentState.PAYMENT_COMPLETE) {
      return buildAwaitingPaymentView(model);
    }
    if (model.agoraCredentials == null ||
        model.callCounterpartyConnectionState ==
            CallServerCounterpartyConnectionState.DISCONNECTED) {
      return CallWaitingJoin(
          onCancelCallTap: onEndCallTap, calledUserMetadata: calledMetadata);
    }
    return buildVideoCallView(context, model);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentWrapper<UserMetadata>?>(
        future: UserMetadata.get(widget.otherUserId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<UserMetadata>?> snapshot) {
          if (snapshot.hasData) {
            final expertUserMetadata = snapshot.data;
            return Consumer<CallServerModel>(builder: (context, model, child) {
              return Scaffold(
                appBar: ClientInCallAppbar(expertUserMetadata!),
                body: buildCallView(context, model, expertUserMetadata),
              );
            });
          } else {
            return Scaffold(
              appBar: AppBar(title: const Text("Expert Call")),
              body: CircularProgressIndicator(),
            );
          }
        });
  }
}

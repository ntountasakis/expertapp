import 'dart:developer';

import 'package:expertapp/src/agora/agora_video_call.dart';
import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CallClientMain extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const CallClientMain(
      {required this.currentUserId, required this.otherUserId});

  @override
  State<CallClientMain> createState() =>
      _CallClientMainState(new CallServerManager(
          currentUserId: currentUserId, otherUserId: otherUserId));
}

class _CallClientMainState extends State<CallClientMain> {
  final CallServerManager callServerManager;

  _CallClientMainState(this.callServerManager);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callServerManager.initiateCall(context);
    });
  }

  Widget buildCallSummary(BuildContext context, CallServerModel model) {
    return Container(
        child: ElevatedButton(
      child: const Text("Exit call and submit review"),
      onPressed: () {
        model.reset();
        context.goNamed(Routes.EXPERT_REVIEW_SUBMIT_PAGE,
            params: {Routes.EXPERT_ID_PARAM: widget.otherUserId});
      },
    ));
  }

  Widget buildVideoCallView(BuildContext context, CallServerModel model) {
    if (model.agoraCredentials == null) {
      return CircularProgressIndicator();
    }
    final agoraChannelName = model.agoraCredentials!.channelName;
    final agoraToken = model.agoraCredentials!.token;
    final agoraUid = model.agoraCredentials!.uid;
    return AgoraVideoCall(
      agoraChannelName: agoraChannelName,
      agoraToken: agoraToken,
      agoraUid: agoraUid,
      onChatButtonTap: onChatButtonTap,
      onEndCallButtonTap: onEndCallTap,
    );
  }

  void onChatButtonTap() {
    context.pushNamed(Routes.EXPERT_CALL_CHAT_PAGE,
        params: {Routes.EXPERT_ID_PARAM: widget.otherUserId});
  }

  void onEndCallTap() {
    final transactionId =
        Provider.of<CallServerModel>(context, listen: false).callTransactionId;
    callServerManager.sendTerminateCallRequest(transactionId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentWrapper<UserMetadata>?>(
        future: UserMetadata.get(widget.otherUserId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<UserMetadata>?> snapshot) {
          if (snapshot.hasData) {
            final expertUserMetadata = snapshot.data;
            return Scaffold(
              appBar: UserPreviewAppbar(expertUserMetadata!),
              body: Consumer<CallServerModel>(builder: (context, model, child) {
                if (model.callBeginPaymentPromptModel.paymentState !=
                    PaymentState.PAYMENT_COMPLETE) {
                  return const Text("Awaiting payment to start call");
                }
                switch (model.callTerminatePaymentPromptModel.paymentState) {
                  case PaymentState.NA:
                    return buildVideoCallView(context, model);
                  case PaymentState.AWAITING_PAYMENT:
                    return const Text("Awaiting payment end call");
                  case PaymentState.PAYMENT_COMPLETE:
                    return buildCallSummary(context, model);
                  case PaymentState.PAYMENT_FAILURE:
                    return const Text("End call payment failure");
                }
              }),
            );
          } else {
            return Scaffold(
              appBar: AppBar(title: const Text("Expert Call")),
              body: CircularProgressIndicator(),
            );
          }
        });
  }
}

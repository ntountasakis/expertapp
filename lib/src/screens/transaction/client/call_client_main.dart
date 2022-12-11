import 'dart:developer';

import 'package:expertapp/src/agora/agora_video_call.dart';
import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
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
  bool exitingOnPaymentCanceled = false;

  _CallClientMainState(this.callServerManager);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callServerManager.initiateCall(context);
    });
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

  void navigateToSubmitReview(CallServerModel model) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      model.reset();
      context.goNamed(Routes.EXPERT_REVIEW_SUBMIT_PAGE,
          params: {Routes.EXPERT_ID_PARAM: widget.otherUserId});
    });
  }


  Future<void> onPaymentCancelled(
      BuildContext context, CallServerModel model) async {
    if (!exitingOnPaymentCanceled) {
      exitingOnPaymentCanceled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        model.reset();
        await widget.lifecycle.refreshOwedBalance();
        context.goNamed(Routes.HOME);
      });
    }
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
              appBar: UserPreviewAppbar(expertUserMetadata!, "Call"),
              body: Consumer<CallServerModel>(builder: (context, model, child) {
                if (model.callBeginPaymentPromptModel.paymentState ==
                    PaymentState.PAYMENT_CANCELLED) {
                  onPaymentCancelled(context, model);
                  return SizedBox();
                }
                if (model.callBeginPaymentPromptModel.paymentState !=
                    PaymentState.PAYMENT_COMPLETE) {
                  return SizedBox();
                }
                switch (model.callTerminatePaymentPromptModel.paymentState) {
                  case PaymentState.NA:
                    return buildVideoCallView(context, model);
                  case PaymentState.AWAITING_PAYMENT:
                    return SizedBox();
                  case PaymentState.PAYMENT_COMPLETE:
                    {
                      navigateToSubmitReview(model);
                      return SizedBox();
                    }
                  case PaymentState.PAYMENT_FAILURE:
                    return const Text("End call payment failure");
                  case PaymentState.PAYMENT_CANCELLED:
                    {
                      onPaymentCancelled(context, model);
                      return SizedBox();
                    }
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

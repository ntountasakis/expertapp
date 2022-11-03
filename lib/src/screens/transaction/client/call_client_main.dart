import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/call_server/widgets/call_server_connection_state_view.dart';
import 'package:expertapp/src/call_server/widgets/call_server_counterparty_connection_state_view.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
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

  Widget buildCallView(BuildContext context, CallServerModel model) {
    return Column(children: [
      Container(
        padding: EdgeInsets.all(8.0),
        child: callServerConnectionStateView(model),
      ),
      Container(
        padding: EdgeInsets.all(8.0),
        child: callServerCounterpartyConnectionStateView(model),
      ),
      SizedBox(
        width: 200,
        height: 100,
      ),
      ElevatedButton(
        child: Text("Finish call"),
        onPressed: () {
          callServerManager.sendTerminateCallRequest(model.callTransactionId);
        },
      ),
      SizedBox(
        width: 200,
        height: 100,
      ),
      ElevatedButton(
        child: Text("Chat"),
        onPressed: () {
          context.pushNamed(Routes.EXPERT_CALL_CHAT_PAGE,
              params: {Routes.EXPERT_ID_PARAM: widget.otherUserId});
        },
      ),
      SizedBox(
        width: 200,
        height: 100,
      ),
      ElevatedButton(
          child: Text("Video"),
          onPressed: () {
            if (model.agoraCredentials == null) {
              log("No agora credentials");
            } else {
              context.pushNamed(Routes.EXPERT_CALL_VIDEO_PAGE, params: {
                Routes.EXPERT_ID_PARAM: widget.otherUserId,
                Routes.AGORA_CHANNEL_NAME_PARAM:
                    model.agoraCredentials!.channelName,
                Routes.AGORA_TOKEN_PARAM: model.agoraCredentials!.token,
                Routes.AGORA_UID_PARAM: model.agoraCredentials!.uid.toString()
              });
            }
          }),
    ]);
  }

  Widget buildCallSummary(BuildContext context) {
    return Container(
        child: ElevatedButton(
      child: const Text("Exit call & submit review"),
      onPressed: () {
        context.goNamed(Routes.EXPERT_REVIEW_SUBMIT_PAGE,
            params: {Routes.EXPERT_ID_PARAM: widget.otherUserId});
      },
    ));
  }

  Widget buildStartCallButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("Pay to start call"),
      onPressed: () {
        callServerManager.initiateCall(context);
      },
    );
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
                if (model.callBeginPaymentPromptModel.paymentState ==
                    PaymentState.NA) {
                  return buildStartCallButton(context);
                }
                if (model.callBeginPaymentPromptModel.paymentState !=
                    PaymentState.PAYMENT_COMPLETE) {
                  return const Text("Awaiting payment to start call");
                }
                switch (model.callTerminatePaymentPromptModel.paymentState) {
                  case PaymentState.NA:
                    return buildCallView(context, model);
                  case PaymentState.AWAITING_PAYMENT:
                    return const Text("Awaiting payment end call");
                  case PaymentState.PAYMENT_COMPLETE:
                    return buildCallSummary(context);
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

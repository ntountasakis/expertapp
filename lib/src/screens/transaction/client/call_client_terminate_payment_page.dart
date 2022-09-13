import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/call_server/widgets/call_server_payment_prompt.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_summary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallClientTerminatePaymentPage extends StatefulWidget {
  final DocumentWrapper<UserMetadata> connectedExpertMetadata;
  final CallServerManager callServerManager;

  const CallClientTerminatePaymentPage(
      {required this.connectedExpertMetadata, required this.callServerManager});

  @override
  State<CallClientTerminatePaymentPage> createState() =>
      _CallClientTerminatePaymentPageState();
}

class _CallClientTerminatePaymentPageState
    extends State<CallClientTerminatePaymentPage> {
  void navigateToNextPage(CallServerModel model) {
    Future.microtask(() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListenableProvider<CallServerModel>.value(
            value: model,
            child: CallClientSummary(
              expertUserMetadata: widget.connectedExpertMetadata,
            ),
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserPreviewAppbar(widget.connectedExpertMetadata),
      body: Consumer<CallServerModel>(builder: (context, model, child) {
        switch (model.callTerminatePaymentPromptModel.paymentState) {
          case PaymentState.READY_TO_PRESENT_PAYMENT:
            showPaymentPrompt(model.callTerminatePaymentPromptModel);
            break;
          case PaymentState.PAYMENT_COMPLETE:
            navigateToNextPage(model);
            break;
          case PaymentState.PAYMENT_FAILURE:
            log("CallClientTerminatePaymentPage: Payment failure error");
            break;
          case PaymentState.WAITING_FOR_PAYMENT_DETAILS:
            break;
        }
        return Text("ClientWrapUp: Waiting for payment...");
      }),
    );
  }
}

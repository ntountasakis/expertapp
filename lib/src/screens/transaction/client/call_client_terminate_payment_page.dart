import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_summary.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallClientTerminatePaymentPage extends StatelessWidget {
  final DocumentWrapper<UserMetadata> connectedExpertMetadata;
  final CallServerManager callServerManager;

  const CallClientTerminatePaymentPage(
      {required this.connectedExpertMetadata, required this.callServerManager});

  Widget callSummaryPage(CallServerModel model) {
    return CallClientSummary(
        expertUserMetadata: connectedExpertMetadata,
        callServerManager: callServerManager);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallServerModel>(builder: (context, model, child) {
      switch (model.callTerminatePaymentPromptModel.paymentState) {
        case PaymentState.READY_TO_PRESENT_PAYMENT:
          log("Payment ready");
          break;
        case PaymentState.PAYMENT_COMPLETE:
          return callSummaryPage(model);
        case PaymentState.PAYMENT_FAILURE:
          log("CallClientTerminatePaymentPage: Payment failure error");
          break;
        case PaymentState.WAITING_FOR_PAYMENT_DETAILS:
          break;
      }
      return Text("ClientWrapUp: Waiting for payment...");
    });
  }
}

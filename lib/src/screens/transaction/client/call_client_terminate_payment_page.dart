import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallClientTerminatePaymentPage extends StatelessWidget {
  const CallClientTerminatePaymentPage();

  @override
  Widget build(BuildContext context) {
    return Consumer<CallServerModel>(builder: (context, model, child) {
      switch (model.callTerminatePaymentPromptModel.paymentState) {
        case PaymentState.PAYMENT_PROMPT_PRESENTED:
          log("Payment ready");
          break;
        case PaymentState.PAYMENT_COMPLETE:
          Navigator.popAndPushNamed(context, Routes.CLIENT_CALL_SUMMARY);
          break;
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

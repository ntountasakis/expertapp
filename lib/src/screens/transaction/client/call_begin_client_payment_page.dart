import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallBeginClientPaymentPage extends StatefulWidget {
  final String currentUserId;
  final DocumentWrapper<UserMetadata> expertUserMetadata;
  final CallServerManager callServerManager;

  const CallBeginClientPaymentPage(
      {required this.currentUserId,
      required this.expertUserMetadata,
      required this.callServerManager});

  @override
  State<CallBeginClientPaymentPage> createState() =>
      _CallBeginClientPaymentPageState();
}

class _CallBeginClientPaymentPageState
    extends State<CallBeginClientPaymentPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero)
        .then((value) => {widget.callServerManager.initiateCall(context)});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserPreviewAppbar(widget.expertUserMetadata),
      body: Consumer<CallServerModel>(
        builder: (context, model, child) {
          switch (model.callBeginPaymentPromptModel.paymentState) {
            case PaymentState.PAYMENT_PROMPT_PRESENTED:
              log("Payment ready");
              break;
            case PaymentState.PAYMENT_COMPLETE:
              Navigator.of(context).popAndPushNamed(Routes.CLIENT_CALL_MAIN);
              break;
            case PaymentState.PAYMENT_FAILURE:
              log("CallClientPaymentBeginPage: Payment failure error");
              break;
            case PaymentState.WAITING_FOR_PAYMENT_DETAILS:
              break;
          }
          return Text("Waiting for payment...");
        },
      ),
    );
  }
}

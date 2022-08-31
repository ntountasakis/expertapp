import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/call_server/widgets/call_server_payment_prompt.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:expertapp/src/screens/transaction/client/call_transaction_client_main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallClientPaymentPage extends StatelessWidget {
  final String currentUserId;
  final DocumentWrapper<UserMetadata> expertUserMetadata;
  final CallServerManager callServerManager;

  const CallClientPaymentPage(
      {required this.currentUserId,
      required this.expertUserMetadata,
      required this.callServerManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserPreviewAppbar(expertUserMetadata),
      body: Consumer<CallServerModel>(
        builder: (context, model, child) {
          if (model.callConnectionState ==
              CallServerConnectionState.DISCONNECTED) {
            callServerManager.initiateCall(context);
          }
          switch (model.callBeginPaymentPromptModel.paymentState) {
            case PaymentState.READY_TO_PRESENT_PAYMENT:
              showPaymentPrompt(model);
              break;
            case PaymentState.PAYMENT_COMPLETE:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return CallTransactionClientMain(
                    currentUserId: currentUserId,
                    connectedExpertMetadata: expertUserMetadata,
                    callServerManager: callServerManager);
              }));
              break;
            case PaymentState.PAYMENT_FAILURE:
              log("CallClientPaymentPage: Payment failure error");
              break;
            case PaymentState.AWAITING_PAYMENT_RESOLVE:
            case PaymentState.WAITING_FOR_PAYMENT_DETAILS:
              break;
          }
          return Text("Waiting for payment...");
        },
      ),
    );
  }
}

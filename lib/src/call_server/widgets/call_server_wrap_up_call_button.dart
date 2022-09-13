import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_terminate_payment_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget callServerWrapUpCallButton(
    BuildContext context,
    CallServerManager manager,
    DocumentWrapper<UserMetadata> connectedExpertMetadata,
    CallServerModel model) {
  return ElevatedButton(
      onPressed: () async {
        manager.sendTerminateCallRequest(model.callTransactionId);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListenableProvider<CallServerModel>.value(
                value: model,
                child: CallClientTerminatePaymentPage(
                    connectedExpertMetadata: connectedExpertMetadata,
                    callServerManager: manager),
              ),
            ));
      },
      child: Text("Wrap Up Call"));
}

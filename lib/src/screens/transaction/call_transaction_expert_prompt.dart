import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/firebase/cloud_messaging/messages/call_join_request.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/transaction/expert/call_transaction_expert_main.dart';
import 'package:flutter/material.dart';

class CallTransactionExpertPrompt extends StatelessWidget {
  final CallJoinRequestTokenPayload callJoinRequest;
  final String currentUserId;
  final DocumentWrapper<UserMetadata> callerUserMetadata;

  const CallTransactionExpertPrompt(
      {required this.callJoinRequest,
      required this.currentUserId,
      required this.callerUserMetadata});

  void navigateToNextPage(BuildContext context) {
    CallServerManager callManager = new CallServerManager(
        currentUserId: currentUserId,
        otherUserId: callerUserMetadata.documentId);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return CallTransactionExpertMain(
        callTransactionId: callJoinRequest.callTransactionId,
        currentUserId: currentUserId,
        callerClientMetadata: callerUserMetadata,
        callServerManager: callManager,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    final callPrompt = 'Call with ${callerUserMetadata.documentType.firstName}';
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(callPrompt),
            ElevatedButton(
              onPressed: () => navigateToNextPage(context),
              child: Text("Join Call"),
            ),
          ],
        ),
      ),
    );
  }
}

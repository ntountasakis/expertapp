import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:flutter/material.dart';

class CallClientSummary extends StatelessWidget {
  final DocumentWrapper<UserMetadata> expertUserMetadata;
  final CallServerManager callServerManager;

  const CallClientSummary(
      {required this.expertUserMetadata, required this.callServerManager});

  Widget exitCallFlowButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          await callServerManager.disconnect();
          Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
        },
        child: Text("Exit Call Flow"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserPreviewAppbar(expertUserMetadata),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(children: [
          exitCallFlowButton(context),
        ]),
      ),
    );
  }
}

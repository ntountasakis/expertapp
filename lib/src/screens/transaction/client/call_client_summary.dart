import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:flutter/material.dart';

class CallClientSummary extends StatelessWidget {
  final DocumentWrapper<UserMetadata> expertUserMetadata;

  const CallClientSummary({required this.expertUserMetadata});

  Widget exitCallFlowButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
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

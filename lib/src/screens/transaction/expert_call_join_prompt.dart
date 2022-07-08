import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/cloud_messaging/messages/call_join_request.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/transaction/expert_call_main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpertCallJoinPrompt extends StatelessWidget {
  final CallJoinRequest request;
  final DocumentWrapper<UserMetadata> callerUserMetadata;

  const ExpertCallJoinPrompt(this.request, this.callerUserMetadata);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Call from User Id: ${request.callerUid}"),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return ChangeNotifierProvider<CallServerModel>(
                    create: (context) => CallServerModel(),
                    child:
                        ExpertCallMain(request.calledUid, callerUserMetadata),
                  );
                }));
              },
              child: const Text('foo'),
            ),
          ],
        ),
      ),
    );
  }
}

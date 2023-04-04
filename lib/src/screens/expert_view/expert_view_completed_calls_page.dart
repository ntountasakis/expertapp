import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/util/completed_calls_util.dart';
import 'package:expertapp/src/util/expert_completed_call_card.dart';
import 'package:flutter/material.dart';

class ExpertViewCompletedCallsPage extends StatelessWidget {
  final String uid;

  ExpertViewCompletedCallsPage(this.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Completed Calls")),
      body: StreamBuilder(
        stream: CallTransaction.getStreamForCalled(calledUid: uid),
        builder: (BuildContext context,
            AsyncSnapshot<Iterable<DocumentWrapper<CallTransaction>>>
                snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final DocumentWrapper<CallTransaction> call =
                      snapshot.data!.elementAt(index);
                  return new ExpertCompletedCallCard(
                      call.documentType, call.documentId,
                      key: Key(call.documentId));
                });
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/util/completed_calls_util.dart';
import 'package:flutter/material.dart';

class CompletedIncomingCallsPage extends StatelessWidget {
  final String uid;

  CompletedIncomingCallsPage(this.uid);

  Widget buildCallCard(
      BuildContext context, CallTransaction call, String transactionId) {
    String title = 'Completed Call with Client';

    String subtitle = 'Ended on ${CompletedCallsUtil.formatEndDate(call)}. '
        'Earned ${CompletedCallsUtil.formatCents(call.earnedTotalCents)} '
        'Length ${CompletedCallsUtil.formatCallLength(call)}';

    return Card(
        key: Key(transactionId),
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: GestureDetector(
            onTap: () {
              showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return CompletedCallsUtil.buildCallPopup(
                        call, transactionId);
                  });
            },
            child: Icon(Icons.more_vert),
          ),
        ));
  }

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
                  return buildCallCard(
                      context, call.documentType, call.documentId);
                });
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

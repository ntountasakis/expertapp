import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/util/completed_calls_util.dart';
import 'package:flutter/material.dart';

class UserViewCompletedCallsPage extends StatelessWidget {
  final String uid;

  UserViewCompletedCallsPage(this.uid);

  Widget buildCallCard(CallTransaction call, String transactionId) {
    return FutureBuilder(
        future: Future.wait([PublicExpertInfo.get(call.calledUid)]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final expertMetadata =
                snapshot.data![0] as DocumentWrapper<PublicExpertInfo>?;

            String title = 'Completed Call';
            if (expertMetadata != null) {
              title += ' with ' + expertMetadata.documentType.fullName();
            }

            String subtitle =
                'Ended on ${CompletedCallsUtil.formatEndDate(call)}. '
                'Paid ${CompletedCallsUtil.formatCents(call.costOfCallCents)} '
                'Length ${CompletedCallsUtil.formatCallLength(call)}';

            return Card(
                key: Key(transactionId),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(subtitle),
                  leading: SizedBox(
                      width: 50,
                      child: ProfilePicture(
                          expertMetadata!.documentType.profilePicUrl)),
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
          return SizedBox();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Completed Calls with Experts")),
      body: StreamBuilder(
        stream: CallTransaction.getStreamForCaller(callerUid: uid),
        builder: (BuildContext context,
            AsyncSnapshot<Iterable<DocumentWrapper<CallTransaction>>>
                snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final DocumentWrapper<CallTransaction> call =
                      snapshot.data!.elementAt(index);
                  return buildCallCard(call.documentType, call.documentId);
                });
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

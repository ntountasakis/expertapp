import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/profile/profile_leading_tile.dart';
import 'package:expertapp/src/util/expert_completed_call_card.dart';
import 'package:expertapp/src/util/tappable_card.dart';
import 'package:flutter/material.dart';

class ExpertViewCompletedCallsPage extends StatelessWidget {
  final String uid;

  ExpertViewCompletedCallsPage(this.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Past Calls with Clients")),
      body: StreamBuilder(
        stream: CallTransaction.getStreamForCalled(calledUid: uid),
        builder: (BuildContext context,
            AsyncSnapshot<Iterable<DocumentWrapper<CallTransaction>>>
                snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return FutureBuilder(
                  future: getDefaultProfilePicUrl(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return buildTappableCard(
                          context: context,
                          leading: buildLeadingProfileTile(
                              context: context,
                              shortName: "",
                              profilePicUrl: snapshot.data!,
                              showOnlineStatus: false,
                              isOnline: false),
                          title: Text("No calls... yet."),
                          subtitle: Text(
                              "After your first call, the details will appear here."),
                          trailing: SizedBox(),
                          onTapCallback: null);
                    } else {
                      return SizedBox();
                    }
                  });
            }
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
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

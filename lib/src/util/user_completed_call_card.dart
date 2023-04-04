import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/util/completed_calls_util.dart';
import 'package:flutter/material.dart';

class UserCompletedCallCard extends StatelessWidget {
  final CallTransaction call;
  final String transactionId;
  const UserCompletedCallCard(this.call, this.transactionId, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([PublicExpertInfo.get(call.calledUid)]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final expertMetadata =
                snapshot.data![0] as DocumentWrapper<PublicExpertInfo>?;

            String title = 'Completed Call';
            if (expertMetadata != null) {
              title += ' with ' + expertMetadata.documentType.shortName();
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
}

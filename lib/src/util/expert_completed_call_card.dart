import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/util/completed_calls_util.dart';
import 'package:flutter/material.dart';

class ExpertCompletedCallCard extends StatelessWidget {
  final CallTransaction call;
  final String transactionId;
  const ExpertCompletedCallCard(this.call, this.transactionId, {Key? key})
      : super(key: key);

  static Widget buildCallCard(
      BuildContext context, String title, String subtitle, VoidCallback onTap) {
    return Card(
        child: ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: GestureDetector(
        onTap: onTap,
        child: Icon(Icons.more_vert),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    String subtitle = 'Ended on ${CompletedCallsUtil.formatEndDate(call)}. '
        'Earned ${CompletedCallsUtil.formatCents(call.earnedTotalCents)} '
        'Length ${CompletedCallsUtil.formatCallLength(call)}';

    return FutureBuilder(
        future: PublicUserInfo.get(call.callerUid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicUserInfo>?> snapshot) {
          String title = 'Completed call with ';
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              title += ' Deleted User';
            } else {
              title += snapshot.data!.documentType.shortName();
            }
            return buildCallCard(context, title, subtitle, () {
              showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return CompletedCallsUtil.buildCallPopup(
                        call, transactionId);
                  });
            });
          } else {
            return SizedBox();
          }
        });
  }
}

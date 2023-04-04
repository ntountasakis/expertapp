import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/util/completed_calls_util.dart';
import 'package:flutter/material.dart';

class ExpertCompletedCallCard extends StatelessWidget {
  final CallTransaction call;
  final String transactionId;
  const ExpertCompletedCallCard(this.call, this.transactionId, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = 'Completed Call with Client';

    String subtitle = 'Ended on ${CompletedCallsUtil.formatEndDate(call)}. '
        'Earned ${CompletedCallsUtil.formatCents(call.earnedTotalCents)} '
        'Length ${CompletedCallsUtil.formatCallLength(call)}';

    return Card(
        child: ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: GestureDetector(
        onTap: () {
          showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return CompletedCallsUtil.buildCallPopup(call, transactionId);
              });
        },
        child: Icon(Icons.more_vert),
      ),
    ));
  }
}

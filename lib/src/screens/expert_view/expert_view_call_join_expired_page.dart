import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/util/time_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertViewCallJoinExpiredPage extends StatelessWidget {
  final String callerShortName;
  final String callTransactionId;

  const ExpertViewCallJoinExpiredPage(
      {required this.callerShortName, required this.callTransactionId});

  Widget buildExpiryExplanation() {
    return FutureBuilder(
      future: CallTransaction.get(callTransactionId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final callTransaction =
              snapshot.data as DocumentWrapper<CallTransaction>;
          final minsAndSecs = convertMillisecondsToMinutesAndSeconds(
              DateTime.now().toUtc().millisecondsSinceEpoch -
                  callTransaction.documentType.callEndTimeUtcMs);
          final mins = minsAndSecs['minutes'];
          final secs = minsAndSecs['seconds'];
          final timeElapsedMsg = '${mins} minutes and ${secs} seconds ago';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "The call from $callerShortName expired ${timeElapsedMsg}. The call timer either elapsed or the they hung up.",
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'If you believe this is an error, please contact support. We are happy to help!',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          "Call Expired",
        ),
      )),
      body: Column(
        children: [
          SizedBox(height: 20),
          buildExpiryExplanation(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.goNamed(Routes.HOME_PAGE);
            },
            child: Text("Back to Home"),
          ),
        ],
      ),
    );
  }
}

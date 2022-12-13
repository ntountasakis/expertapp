import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:expertapp/src/util/currency_util.dart';
import 'package:flutter/material.dart';

class ClientInCallAppbar extends StatelessWidget with PreferredSizeWidget {
  final DocumentWrapper<UserMetadata> userMetadata;
  final String namePrefix;
  final CallServerModel model;

  ClientInCallAppbar(this.userMetadata, this.namePrefix, this.model);

  String buildTitle() {
    return namePrefix + " " + userMetadata.documentType.firstName;
  }

  Widget buildCostDialog() {
    int callLengthSec = model.callLengthSeconds();
    if (model.feeBreakdowns != null && callLengthSec != 0) {
      return Center(
        child: Column(
          children: [
            Text(callLength(callLengthSec)),
            Text(prepaidStartCall(model.feeBreakdowns!)),
            Text(timeCharges(model.feeBreakdowns!, callLengthSec)),
            Text(total(model.feeBreakdowns!, callLengthSec)),
          ],
        ),
      );
    }
    return SizedBox();
  }

  Widget costButton(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.green[900],
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Center(
                      child: Text(
                        "Estimated Cost",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    children: [
                      buildCostDialog(),
                    ],
                  );
                });
          },
          icon: Icon(
            Icons.monetization_on,
            size: 30,
            color: Colors.green,
          ),
        ));
  }

  int timeChargesCents(ServerFeeBreakdowns fees, int callLengthSec) {
    int centsRunningTime =
        (fees.earnedCentsPerMinute * (callLengthSec / 60.0)).round();
    return centsRunningTime;
  }

  int totalCents(ServerFeeBreakdowns fees, int callLengthSec) {
    return fees.earnedCentsStartCall + timeChargesCents(fees, callLengthSec);
  }

  String callLength(int callLengthSec) {
    return 'Elapsed seconds: ${callLengthSec}';
  }

  String prepaidStartCall(ServerFeeBreakdowns fees) {
    return 'Already paid: ${formattedRate(fees.earnedCentsStartCall)}';
  }

  String timeCharges(ServerFeeBreakdowns fees, int callLengthSec) {
    return 'Time charges: ${formattedRate(timeChargesCents(fees, callLengthSec))}';
  }

  String total(ServerFeeBreakdowns fees, int callLengthSec) {
    String fmtAmt = formattedRate(totalCents(fees, callLengthSec));
    return 'Running total: ${fmtAmt}';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(buildTitle()),
          ),
          SizedBox(
            width: 15,
          ),
          costButton(context),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

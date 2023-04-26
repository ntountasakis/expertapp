import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:expertapp/src/util/currency_util.dart';
import 'package:flutter/material.dart';

Widget costButton(BuildContext context, CallServerModel model) {
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
                    buildCostDialog(model),
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

Widget buildCostDialog(CallServerModel model) {
  int callLengthSec = model.callElapsedSeconds();
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

String callLength(int callLengthSec) {
  return 'Elapsed seconds: ${callLengthSec}';
}

String prepaidStartCall(ServerFeeBreakdowns fees) {
  return 'Fee to start call: ${formattedRate(fees.earnedCentsStartCall)}';
}

String timeCharges(ServerFeeBreakdowns fees, int callLengthSec) {
  return 'Time charges: ${formattedRate(timeChargesCents(fees, callLengthSec))}';
}

String total(ServerFeeBreakdowns fees, int callLengthSec) {
  String fmtAmt = formattedRate(totalCents(fees, callLengthSec));
  return 'Running total: ${fmtAmt}';
}

int timeChargesCents(ServerFeeBreakdowns fees, int callLengthSec) {
  int centsRunningTime =
      (fees.earnedCentsPerMinute * (callLengthSec / 60.0)).round();
  return centsRunningTime;
}

int totalCents(ServerFeeBreakdowns fees, int callLengthSec) {
  return fees.earnedCentsStartCall + timeChargesCents(fees, callLengthSec);
}

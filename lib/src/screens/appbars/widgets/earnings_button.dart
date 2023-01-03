import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:expertapp/src/util/currency_util.dart';
import 'package:flutter/material.dart';

Widget buildEarningsDialog(CallServerModel model) {
  int callLengthSec = model.callLengthSeconds();
  if (model.feeBreakdowns != null && callLengthSec != 0) {
    return Center(
      child: Column(
        children: [
          Text(callLength(callLengthSec)),
          Text(beforeFees(model.feeBreakdowns!, callLengthSec)),
          Text(paymentProcessorFees(model.feeBreakdowns!, callLengthSec)),
          Text(platformFees(model.feeBreakdowns!, callLengthSec)),
          Text(total(model.feeBreakdowns!, callLengthSec)),
        ],
      ),
    );
  }
  return Center(
    child: Text("No earnings yet, await client connection"),
  );
}

Widget earningsButton(BuildContext context, CallServerModel model) {
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
                      "Estimated Call Earnings",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  children: [
                    buildEarningsDialog(model),
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

int subtotalCents(ServerFeeBreakdowns fees, int callLengthSec) {
  int centsRunningTime =
      (fees.earnedCentsPerMinute * (callLengthSec / 60.0)).round();
  return centsRunningTime + fees.earnedCentsStartCall;
}

int paymentProcessorFeesCents(ServerFeeBreakdowns fees, int callLengthSec) {
  return (subtotalCents(fees, callLengthSec) *
              (fees.paymentProcessorPercentFee / 100))
          .round() +
      fees.paymentProcessorCentsFlatFee;
}

int platformFeeCents(ServerFeeBreakdowns fees, int callLengthSec) {
  int amtBeforePlatformFee = subtotalCents(fees, callLengthSec) -
      paymentProcessorFeesCents(fees, callLengthSec);
  return (amtBeforePlatformFee * (fees.platformPercentFee / 100)).round();
}

int totalCents(ServerFeeBreakdowns fees, int callLengthSec) {
  return subtotalCents(fees, callLengthSec) -
      paymentProcessorFeesCents(fees, callLengthSec);
}

String callLength(int callLengthSec) {
  return 'Elapsed seconds: ${callLengthSec}';
}

String beforeFees(ServerFeeBreakdowns fees, int callLengthSec) {
  String fmtAmt = formattedRate(subtotalCents(fees, callLengthSec));
  return 'Before Fees: ${fmtAmt}';
}

String paymentProcessorFees(ServerFeeBreakdowns fees, int callLengthSec) {
  String fmtAmt = formattedRate(paymentProcessorFeesCents(fees, callLengthSec));
  return 'Payment Processor Fees: ${fmtAmt}';
}

String platformFees(ServerFeeBreakdowns fees, int callLengthSec) {
  String fmtAmt = formattedRate(platformFeeCents(fees, callLengthSec));
  return 'Platform Fees: ${fmtAmt}';
}

String total(ServerFeeBreakdowns fees, int callLengthSec) {
  String fmtAmt = formattedRate(totalCents(fees, callLengthSec));
  return 'Earned Total: ${fmtAmt}';
}

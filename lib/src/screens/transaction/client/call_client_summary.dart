import 'dart:developer';

import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:expertapp/src/util/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../call_server/call_server_model.dart';

class CallClientSummary extends StatefulWidget {
  final String otherUserId;

  const CallClientSummary({required this.otherUserId});

  @override
  State<CallClientSummary> createState() => _CallClientSummaryState();
}

class _CallClientSummaryState extends State<CallClientSummary> {
  bool exiting = false;

  final ButtonStyle buttonStyle =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  final boldStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.grey[800],
  );

  final lightStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey[800],
  );

  Widget buildHomeButton(CallServerModel model) {
    return ElevatedButton(
      style: buttonStyle,
      onPressed: () async {
        exiting = true;
        model.reset();
        context.goNamed(Routes.HOME);
      },
      child: Text("Finish"),
    );
  }

  Widget buildLeaveReviewButton() {
    return ElevatedButton(
      style: buttonStyle,
      onPressed: () async {
        context.goNamed(Routes.EXPERT_REVIEW_SUBMIT_PAGE,
            params: {Routes.EXPERT_ID_PARAM: widget.otherUserId});
      },
      child: Text("Leave Review"),
    );
  }

  String callLengthFormat(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}\h $twoDigitMinutes\m $twoDigitSeconds\s";
  }

  Widget buildCallLength(ServerCallSummary summary) {
    final duration = Duration(seconds: summary.lengthOfCallSec);
    return Text(
      "Call Length: " + callLengthFormat(duration),
      style: boldStyle,
    );
  }

  Widget buildCostOfCall(ServerCallSummary summary) {
    final cost = formattedRate(summary.costOfCallCents);
    return Text(
      "Cost of Call: " + cost,
      style: boldStyle,
    );
  }

  Widget buildCallSummaryBlurb(ServerCallSummary summary) {
    final blurb =
        """Your payment method was charged ${formattedRate(summary.costOfCallCents)} for the call. We have cancelled the hold on the remaining amount that was authorized at the start of the call. Please consider leaving a review. Thank you for using ExpertApp!""";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        blurb,
        style: lightStyle,
      ),
    );
  }

  Widget buildSummaryBody(BuildContext context) {
    final model = Provider.of<CallServerModel>(context);
    if (model.callSummary == null) {
      if (!exiting) {
        exiting = true;
        log('Call summary is null. Exiting to home');
        model.reset();
        context.goNamed(Routes.HOME);
      }
      return SizedBox();
    }

    final callSummary = model.callSummary!;
    return Container(
        child: Column(
      children: [
        SizedBox(height: 20),
        buildCostOfCall(callSummary),
        SizedBox(height: 20),
        buildCallLength(callSummary),
        SizedBox(height: 20),
        buildCallSummaryBlurb(callSummary),
        SizedBox(height: 50),
        Row(
          children: [
            SizedBox(width: 10),
            buildLeaveReviewButton(),
            Expanded(child: Container()),
            buildHomeButton(model),
            SizedBox(width: 10),
          ],
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Summary'),
      ),
      body: buildSummaryBody(context),
    );
  }
}

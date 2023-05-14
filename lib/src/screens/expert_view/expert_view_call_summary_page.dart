import 'dart:developer';

import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../call_server/call_server_model.dart';

class ExpertViewCallSummaryPage extends StatefulWidget {
  @override
  State<ExpertViewCallSummaryPage> createState() =>
      _ExpertViewCallSummaryPageState();
}

class _ExpertViewCallSummaryPageState extends State<ExpertViewCallSummaryPage> {
  bool exiting = false;

  void goHome(CallServerModel model) {
    exiting = true;
    model.reset();
    context.goNamed(Routes.HOME_PAGE);
  }

  Widget buildSummaryBody(BuildContext context) {
    final model = Provider.of<CallServerModel>(context);
    if (model.callSummary == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        if (!exiting) {
          log('Call summary is null. Exiting to home');
          goHome(model);
        }
      });
      return SizedBox();
    }

    final callSummary = model.callSummary!;
    return Container(
        child: Column(
      children: [
        SizedBox(height: 20),
        CallSummaryUtil.buildCallLength(callSummary),
        SizedBox(height: 20),
        CallSummaryUtil.buildCallEarningsSubtotal(callSummary),
        SizedBox(height: 20),
        CallSummaryUtil.buildCallEarningsPlatformFee(callSummary),
        SizedBox(height: 20),
        CallSummaryUtil.buildCallEarningsAmountEarned(callSummary),
        SizedBox(height: 50),
        CallSummaryUtil.buildExpertCallSummaryBlurb(callSummary),
        Row(
          children: [
            Expanded(child: Container()),
            CallSummaryUtil.buildButton(model, "Finish", goHome),
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

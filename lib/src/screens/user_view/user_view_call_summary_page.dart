import 'dart:developer';

import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../call_server/call_server_model.dart';

class UserViewCallSummaryPage extends StatefulWidget {
  final String otherUserId;

  const UserViewCallSummaryPage({required this.otherUserId});

  @override
  State<UserViewCallSummaryPage> createState() =>
      _UserViewCallSummaryPageState();
}

class _UserViewCallSummaryPageState extends State<UserViewCallSummaryPage> {
  bool exiting = false;

  void goSubmitReview(CallServerModel model) {
    context.goNamed(Routes.UV_REVIEW_SUBMIT_PAGE,
        pathParameters: {Routes.EXPERT_ID_PARAM: widget.otherUserId});
  }

  void goHome(CallServerModel model) {
    exiting = true;
    model.reset();
    context.goNamed(Routes.HOME_PAGE);
  }

  Widget buildSummaryBodyCallFinished(CallServerModel model) {
    final callSummary = model.callSummary!;
    return Container(
        child: Column(
      children: [
        SizedBox(height: 20),
        CallSummaryUtil.buildCostOfCall(callSummary),
        SizedBox(height: 20),
        CallSummaryUtil.buildCallLength(callSummary),
        SizedBox(height: 20),
        CallSummaryUtil.buildClientCallFinishedSummaryBlurb(callSummary),
        SizedBox(height: 50),
        Row(
          children: [
            SizedBox(width: 10),
            CallSummaryUtil.buildButton(model, "Leave Review", goSubmitReview),
            Expanded(child: Container()),
            CallSummaryUtil.buildButton(model, "Finish", goHome),
            SizedBox(width: 10),
          ],
        )
      ],
    ));
  }

  Widget buildSummaryBodyCallCanceled(CallServerModel model) {
    return Container(
        child: Column(
      children: [
        SizedBox(height: 20),
        CallSummaryUtil.buildClientCallCanceledSummaryBlurb(
            model.callPaymentPromptModel),
        SizedBox(height: 50),
        CallSummaryUtil.buildButton(model, "Finish", goHome),
        SizedBox(width: 10),
      ],
    ));
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
    if (model.callSummary!.lengthOfCallSec != 0) {
      return buildSummaryBodyCallFinished(model);
    } else {
      return buildSummaryBodyCallCanceled(model);
    }
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

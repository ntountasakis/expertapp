import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/appbars/expert_view/expert_call_prompt_appbar.dart';
import 'package:expertapp/src/util/call_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

class ExpertViewCallJoinPromptPage extends StatefulWidget {
  final int callJoinExpirationTimeUtcMs;
  final String transactionId;
  final String callerUserId;
  final ExpertRate expertRate;

  const ExpertViewCallJoinPromptPage(
      {required this.callJoinExpirationTimeUtcMs,
      required this.transactionId,
      required this.callerUserId,
      required this.expertRate});

  @override
  State<ExpertViewCallJoinPromptPage> createState() =>
      _ExpertViewCallJoinPromptPageState();
}

class _ExpertViewCallJoinPromptPageState
    extends State<ExpertViewCallJoinPromptPage> {
  bool navigatingToExpiredPage = false;

  Widget buildCallPrompt(PublicUserInfo caller) {
    String promptText =
        '${caller.firstName} will pay you ${widget.expertRate.formattedStartCallFee()} to start the call'
        ' and ${widget.expertRate.formattedPerMinuteFee()} for each minute thereafter.  The billed time will stop if'
        ' either of you end the call or get disconnected.';
    final style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.grey[800],
    );

    return SizedBox(
      width: 300,
      child: Text(promptText, style: style),
    );
  }

  void onCallAcceptTap(PublicUserInfo caller) {
    context.goNamed(Routes.EV_CALL_HOME_PAGE, pathParameters: {
      Routes.CALLER_UID_PARAM: widget.callerUserId,
      Routes.CALL_TRANSACTION_ID_PARAM: widget.transactionId,
      Routes.OTHER_USER_SHORT_NAME: caller.shortName(),
    });
  }

  void navigateHome() {
    context.goNamed(Routes.HOME_PAGE);
  }

  void navigateCallExpiredPage(PublicUserInfo caller) {
    context.goNamed(Routes.EV_CALL_JOIN_EXPIRED_PAGE, pathParameters: {
      Routes.CALL_TRANSACTION_ID_PARAM: widget.transactionId,
      Routes.OTHER_USER_SHORT_NAME: caller.shortName(),
    });
  }

  Widget buildCallButtons(BuildContext context, PublicUserInfo caller) {
    return callButtonRow(context, [
      endCallButton(navigateHome),
      SizedBox(
        width: 50,
      ),
      startCallButton(() => onCallAcceptTap(caller)),
    ]);
  }

  Widget buildCallJoinPromptBody(
      BuildContext context, PublicUserInfo callerInfo) {
    return Scaffold(
        appBar: ExpertCallPromptAppbar(
          widget.callJoinExpirationTimeUtcMs,
          callerInfo.firstName,
          () => navigateCallExpiredPage(callerInfo),
        ),
        body: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(children: [
            SizedBox(
              height: 50,
            ),
            buildCallPrompt(callerInfo),
            SizedBox(
              height: 10,
            ),
            buildCallButtons(context, callerInfo),
          ]),
        ));
  }

  Widget bodyWrapper(BuildContext context, PublicUserInfo callerInfo) {
    return StreamBuilder(
        stream: CallTransaction.getStreamForTransaction(widget.transactionId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<CallTransaction>> snapshot) {
          if (snapshot.hasData) {
            DocumentWrapper<CallTransaction>? callTransaction = snapshot.data;
            if (callTransaction != null &&
                callTransaction.documentType.callEndTimeUtcMs != 0) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (!navigatingToExpiredPage) {
                  navigateCallExpiredPage(callerInfo);
                }
                setState(() {
                  navigatingToExpiredPage = true;
                });
              });
            }
            return buildCallJoinPromptBody(context, callerInfo);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentWrapper<PublicUserInfo>?>(
        future: PublicUserInfo.get(widget.callerUserId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicUserInfo>?> snapshot) {
          if (snapshot.hasData) {
            final callerInfo = snapshot.data;
            return bodyWrapper(context, callerInfo!.documentType);
          }
          return Scaffold();
        });
  }
}

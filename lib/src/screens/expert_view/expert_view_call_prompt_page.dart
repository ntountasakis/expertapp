import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/appbars/expert_view/expert_call_prompt_appbar.dart';
import 'package:expertapp/src/util/call_buttons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertViewCallPromptPage extends StatefulWidget {
  final String transactionId;
  final String currentUserId;
  final String callerUserId;
  final ExpertRate expertRate;
  final int callJoinExpirationTimeUtcMs;

  const ExpertViewCallPromptPage(
      {required this.transactionId,
      required this.currentUserId,
      required this.callerUserId,
      required this.expertRate,
      required this.callJoinExpirationTimeUtcMs});

  @override
  State<ExpertViewCallPromptPage> createState() =>
      _ExpertViewCallPromptPageState();
}

class _ExpertViewCallPromptPageState extends State<ExpertViewCallPromptPage> {
  Widget buildCallPrompt(DocumentWrapper<PublicUserInfo> caller) {
    String promptText =
        '${caller.documentType.firstName} will pay you ${widget.expertRate.formattedStartCallFee()} to start the call'
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

  void onCallAcceptTap() {
    context.goNamed(Routes.EV_CALL_HOME_PAGE, params: {
      Routes.CALLER_UID_PARAM: widget.callerUserId,
      Routes.CALL_TRANSACTION_ID_PARAM: widget.transactionId
    });
  }

  void navigateHome() {
    context.goNamed(Routes.HOME_PAGE);
  }

  Widget buildCallButtons(BuildContext context) {
    return callButtonRow(context, [
      endCallButton(navigateHome),
      SizedBox(
        width: 50,
      ),
      startCallButton(onCallAcceptTap),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentWrapper<PublicUserInfo>?>(
        future: PublicUserInfo.get(widget.callerUserId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicUserInfo>?> snapshot) {
          if (snapshot.hasData) {
            final callerMetadata = snapshot.data;
            return Scaffold(
                appBar: ExpertCallPromptAppbar(
                  widget.callJoinExpirationTimeUtcMs,
                  callerMetadata!.documentType.firstName,
                  navigateHome,
                ),
                body: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(children: [
                    SizedBox(
                      height: 50,
                    ),
                    buildCallPrompt(callerMetadata),
                    SizedBox(
                      height: 10,
                    ),
                    buildCallButtons(context),
                  ]),
                ));
          }
          return Scaffold();
        });
  }
}

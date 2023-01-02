import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/screens/appbars/expert_call_prompt_appbar.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:expertapp/src/util/call_buttons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CallTransactionExpertPrompt extends StatefulWidget {
  final String transactionId;
  final String currentUserId;
  final String callerUserId;
  final ExpertRate expertRate;
  final int callJoinExpirationTimeUtcMs;

  const CallTransactionExpertPrompt(
      {required this.transactionId,
      required this.currentUserId,
      required this.callerUserId,
      required this.expertRate,
      required this.callJoinExpirationTimeUtcMs});

  @override
  State<CallTransactionExpertPrompt> createState() =>
      _CallTransactionExpertPromptState();
}

class _CallTransactionExpertPromptState
    extends State<CallTransactionExpertPrompt> {
  Widget buildCallPrompt(DocumentWrapper<UserMetadata> caller) {
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
    context.goNamed(Routes.CLIENT_CALL_HOME, params: {
      Routes.CALLER_UID_PARAM: widget.callerUserId,
      Routes.CALL_TRANSACTION_ID_PARAM: widget.transactionId
    });
  }

  void onCallDeclineTap() {
    context.goNamed(Routes.HOME);
  }

  Widget buildCallButtons(BuildContext context) {
    return callButtonRow(context, [
      endCallButton(onCallDeclineTap),
      SizedBox(
        width: 50,
      ),
      startCallButton(onCallAcceptTap),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentWrapper<UserMetadata>?>(
        future: UserMetadata.get(widget.callerUserId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<UserMetadata>?> snapshot) {
          if (snapshot.hasData) {
            final callerMetadata = snapshot.data;
            return Scaffold(
                appBar: ExpertCallPromptAppbar(
                    widget.callJoinExpirationTimeUtcMs,
                    callerMetadata!.documentType.firstName),
                body: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(children: [
                    SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: ProfilePicture(
                          callerMetadata.documentType.profilePicUrl),
                    ),
                    SizedBox(
                      height: 10,
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

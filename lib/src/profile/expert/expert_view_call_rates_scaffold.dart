import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_signup_progress.dart';
import 'package:expertapp/src/profile/expert/expert_rate_picker.dart';
import 'package:expertapp/src/util/currency_util.dart';
import 'package:flutter/material.dart';

class ExpertViewCallRatesScaffold extends StatelessWidget {
  final String uid;
  final bool fromSignupFlow;
  final PreferredSizeWidget Function(BuildContext context,
      DocumentWrapper<ExpertSignupProgress>? progress)? appBarBuilder;
  static String DEFAULT_APP_BAR_TITLE = "Update Call Prices";

  const ExpertViewCallRatesScaffold(
      {required this.uid,
      required this.fromSignupFlow,
      required this.appBarBuilder});

  static PreferredSizeWidget buildDefaultAppBar() {
    return AppBar(
      title: Text(DEFAULT_APP_BAR_TITLE),
    );
  }


  Widget buildExistingRateView(DocumentWrapper<ExpertRate>? expertRate) {
    if (expertRate == null) {
      return Text("You have no rate registered yet.");
    }
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(children: [
          Text(
              "You will earn money for accepting calls with the following rates."),
          SizedBox(
            height: 20,
          ),
          Text("Current rate earned per minute: " +
              formattedRate(expertRate.documentType.centsPerMinute)),
          SizedBox(
            height: 20,
          ),
          Text("Current rate earned to accept a call: " +
              formattedRate(expertRate.documentType.centsCallStart)),
        ]));
  }

  Widget buildExpertRateSelector(
      BuildContext context, DocumentWrapper<ExpertRate>? expertRate) {
    num existingRatePerMinute = 0;
    num existingRateStartCall = 0;
    if (expertRate != null) {
      existingRatePerMinute = expertRate.documentType.centsPerMinute;
      existingRateStartCall = expertRate.documentType.centsCallStart;
    }
    return new RatePickers(
      initialValueRateStartCall: existingRateStartCall,
      initialValueRatePerMinute: existingRatePerMinute,
      fromSignUpFlow: fromSignupFlow,
    );
  }

  Widget buildBody(BuildContext context, DocumentWrapper<ExpertRate>? rate) {
    if (rate != null) {
      return Column(
        children: [
          buildExistingRateView(rate),
          SizedBox(
            height: 40,
          ),
          buildExpertRateSelector(context, rate),
        ],
      );
    }
    return SizedBox();
  }

  Widget buildHelper(
      BuildContext context,
      AsyncSnapshot<DocumentWrapper<ExpertRate>?> expertRateSnapshot,
      AsyncSnapshot<DocumentWrapper<ExpertSignupProgress>?>? progressSnapshot) {
    if (!expertRateSnapshot.hasData) {
      return Scaffold(
        appBar: buildDefaultAppBar(),
        body: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: appBarBuilder != null
          ? appBarBuilder!(context, progressSnapshot?.data)
          : buildDefaultAppBar(),
      body: buildBody(context, expertRateSnapshot.data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentWrapper<ExpertRate>?>(
        stream: ExpertRate.getStream(uid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<ExpertRate>?>
                publicExpertInfoSnapshot) {
          if (!fromSignupFlow) {
            return buildHelper(context, publicExpertInfoSnapshot, null);
          } else {
            return StreamBuilder<DocumentWrapper<ExpertSignupProgress>?>(
                stream: ExpertSignupProgress.getStreamForUser(uid: uid),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentWrapper<ExpertSignupProgress>?>
                        expertSignupProgressSnapshot) {
                  return buildHelper(context, publicExpertInfoSnapshot,
                      expertSignupProgressSnapshot);
                });
          }
        });
  }
}

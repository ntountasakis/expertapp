import 'package:expertapp/src/appbars/expert_view/expert_post_signup_appbar.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_signup_progress.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/expert/expert_view_call_rates_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertViewUpdateRatesSignUpPage extends StatelessWidget {
  final String uid;

  const ExpertViewUpdateRatesSignUpPage({required this.uid});

  void onDisallowedProceedPressed(
      BuildContext context, ExpertSignupProgress progress) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Please update your call rates"),
            content: Text(
                "You must update your call rates before proceeding further"),
          );
        });
  }

  void onProceedPressed(BuildContext context) {
    context.pushNamed(Routes.EV_PROFILE_EDIT_PAGE,
        pathParameters: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "true"});
  }

  PreferredSizeWidget buildAppBar(
      BuildContext context, DocumentWrapper<ExpertSignupProgress>? progress) {
    if (progress == null) {
      return ExpertViewCallRatesScaffold.buildDefaultAppBar();
    }
    final builder = ExpertPostSignupAppbar(
      uid: uid,
      titleText: progress.documentType.updatedCallRate
          ? 'Next: Edit Your Profile'
          : ExpertViewCallRatesScaffold.DEFAULT_APP_BAR_TITLE,
      progress: progress.documentType,
      allowBackButton: true,
      allowProceed: progress.documentType.updatedCallRate,
      onDisallowedProceedPressed: onDisallowedProceedPressed,
      onAllowProceedPressed: onProceedPressed,
    );
    return builder.buildAppBar(context);
  }

  @override
  Widget build(BuildContext context) {
    return ExpertViewCallRatesScaffold(
      uid: uid,
      fromSignupFlow: true,
      appBarBuilder: buildAppBar,
    );
  }
}

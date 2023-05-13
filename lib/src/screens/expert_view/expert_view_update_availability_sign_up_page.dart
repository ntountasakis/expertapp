import 'package:expertapp/src/appbars/expert_view/expert_post_signup_appbar.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_signup_progress.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/expert/expert_view_availability_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertViewUpdateAvailabilitySignUpPage extends StatelessWidget {
  final String uid;
  late final ExpertViewUpdateAvailabilityScaffold scaffold;

  ExpertViewUpdateAvailabilitySignUpPage({required this.uid}) {
    scaffold = ExpertViewUpdateAvailabilityScaffold(
      uid: uid,
      fromSignupFlow: true,
      appBarBuilder: buildAppbar,
    );
  }

  void onDisallowedProceedPressed(
      BuildContext context, ExpertSignupProgress progress) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Please update your availability"),
            content:
                Text("You must update your availability before proceeding"),
          );
        });
  }

  void onProceedPressed(BuildContext context) {
    context.pushNamed(Routes.EV_UPDATE_RATE_PAGE,
        pathParameters: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "true"});
  }

  PreferredSizeWidget buildAppbar(
      BuildContext context, DocumentWrapper<ExpertSignupProgress>? progress) {
    if (progress == null) {
      return ExpertViewUpdateAvailabilityScaffold.defaultAppBar();
    }
    final allowProceed = progress.documentType.updatedAvailability;
    final builder = ExpertPostSignupAppbar(
      uid: uid,
      titleText: allowProceed
          ? "Next: Set Your Rates"
          : ExpertViewUpdateAvailabilityScaffold.DEFAULT_APP_BAR_TITLE,
      progress: progress.documentType,
      allowBackButton: true,
      allowProceed: progress.documentType.updatedAvailability,
      onDisallowedProceedPressed: onDisallowedProceedPressed,
      onAllowProceedPressed: onProceedPressed,
    );
    return builder.buildAppBar(context);
  }

  @override
  Widget build(BuildContext context) {
    return scaffold;
  }
}

import 'package:expertapp/src/appbars/expert_view/expert_post_signup_appbar.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_signup_progress.dart';
import 'package:expertapp/src/firebase/firestore/document_models/private_user_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/expert/expert_phone_number_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class ExpertViewUpdatePhoneNumberSignUpPage extends StatelessWidget {
  final String uid;
  const ExpertViewUpdatePhoneNumberSignUpPage({Key? key, required this.uid})
      : super(key: key);

  Widget buildBody(BuildContext context, PrivateUserInfo privateUserInfo) {
    return Column(
      children: [
        ExpertPhoneNumberPicker(
          key: Key('expert_phone_number_picker_sign_up'),
          initialPhoneNumber: privateUserInfo.phoneNumber,
          initialPhoneNumberIsoCode: privateUserInfo.phoneNumberIsoCode,
          initialConsentStatus: privateUserInfo.consentsToSms,
          fromSignUpFlow: true,
        ),
      ],
    );
  }

  static void onProceedPressed(BuildContext context) {
    context.pushNamed(Routes.EV_UPDATE_AVAILABILITY_PAGE,
        pathParameters: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "true"});
  }

  void onDisallowedProceedPressed(
      BuildContext context, ExpertSignupProgress progress) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Please update your contact preferences"),
            content: Text(
                "You must update your contact preferences before proceeding"),
          );
        });
  }

  PreferredSizeWidget buildAppbar(
      BuildContext context, DocumentWrapper<ExpertSignupProgress>? progress) {
    if (progress == null) {
      throw Exception(
          "Expected progress to be non-null for connected account signup page");
    }
    final allowProceed = progress.documentType.updatedSmsPreferences;
    final builder = ExpertPostSignupAppbar(
      uid: uid,
      titleText: 'Press arrow to continue',
      progress: progress.documentType,
      allowBackButton: true,
      allowProceed: allowProceed,
      onDisallowedProceedPressed: onDisallowedProceedPressed,
      onAllowProceedPressed: onProceedPressed,
    );
    return builder.buildAppBar(context);
  }

  Widget buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
          title: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          "Update Contact Preferences",
        ),
      )),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ExpertSignupProgress.getStreamForUser(uid: uid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<ExpertSignupProgress>?> snapshot) {
          if (!snapshot.hasData) {
            return buildLoadingScreen();
          }
          final progress =
              snapshot.data as DocumentWrapper<ExpertSignupProgress>;
          return FutureBuilder(
              future: PrivateUserInfo.get(uid),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentWrapper<PrivateUserInfo>?> snapshot) {
                if (!snapshot.hasData) {
                  return buildLoadingScreen();
                }
                final privateUserInfo =
                    snapshot.data as DocumentWrapper<PrivateUserInfo>;
                return Scaffold(
                  appBar: buildAppbar(context, progress),
                  body: buildBody(context, privateUserInfo.documentType),
                );
              });
        });
  }
}

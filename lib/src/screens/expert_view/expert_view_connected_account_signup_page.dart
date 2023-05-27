import 'package:expertapp/src/appbars/expert_view/expert_post_signup_appbar.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_functions.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_signup_progress.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/util/webview_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertViewConnectedAccountSignupPage extends StatelessWidget {
  final String uid;
  late final WebviewWrapper webview;
  ExpertViewConnectedAccountSignupPage({required this.uid}) {
    webview = WebviewWrapper(
        initUrl: HttpEndpoints.getExpertConnectedAccountSignup(this.uid));
  }

  static void onProceedPressed(BuildContext context) {
    context.pushNamed(Routes.EV_UPDATE_PHONE_NUMBER_PAGE,
        pathParameters: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "true"});
  }

  PreferredSizeWidget defaultAppBar() {
    return AppBar(
      title: Text("Sign up for an expert account"),
    );
  }

  PreferredSizeWidget buildAppbar(
      BuildContext context, DocumentWrapper<ExpertSignupProgress>? snapshot) {
    if (snapshot == null) {
      throw Exception(
          "Expected progress to be non-null for connected account signup page");
    }
    final builder = ExpertPostSignupAppbar(
      uid: uid,
      titleText: 'Next: Set contact preferences',
      progress: snapshot.documentType,
      allowBackButton: true,
      allowProceed: true,
      onDisallowedProceedPressed: null,
      onAllowProceedPressed: onProceedPressed,
    );
    return builder.buildAppBar(context);
  }

  Widget buildHelper(
      BuildContext context,
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> expertInfoSnapshot,
      AsyncSnapshot<DocumentWrapper<ExpertSignupProgress>?> progressSnapshot) {
    final body = Center(
      child: webview,
    );
    if (!expertInfoSnapshot.hasData && !progressSnapshot.hasData) {
      return Scaffold(
        appBar: defaultAppBar(),
        body: body,
      );
    }
    return Scaffold(
      appBar: buildAppbar(context, progressSnapshot.data),
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentWrapper<PublicExpertInfo>?>(
        stream:
            PublicExpertInfo.getStreamForUser(uid: uid, fromSignUpFlow: true),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?>
                publicExpertInfoSnapshot) {
          return StreamBuilder<DocumentWrapper<ExpertSignupProgress>?>(
              stream: ExpertSignupProgress.getStreamForUser(uid: uid),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentWrapper<ExpertSignupProgress>?>
                      expertSignupProgressSnapshot) {
                return buildHelper(context, publicExpertInfoSnapshot,
                    expertSignupProgressSnapshot);
              });
        });
  }
}

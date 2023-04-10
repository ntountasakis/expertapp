import 'package:expertapp/src/appbars/expert_view/expert_post_signup_appbar.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_functions.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
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

  void onProceedPressed(BuildContext context) {
    context.pushNamed(Routes.EV_UPDATE_AVAILABILITY_PAGE,
        params: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "true"});
  }

  PreferredSizeWidget _buildAppbar(
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    if (snapshot.hasData) {
      return ExpertPostSignupAppbar(
        uid: uid,
        titleText: 'Continue to set your availability',
        allowBackButton: false,
        allowProceed: true,
        onDisallowedProceedPressed: null,
        onAllowProceedPressed: onProceedPressed,
      );
    }
    return AppBar(
      title: const Text('Sign up for expert account'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentWrapper<PublicExpertInfo>?>(
        stream:
            PublicExpertInfo.getStreamForUser(uid: uid, fromSignUpFlow: true),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
          return Scaffold(
              appBar: _buildAppbar(snapshot),
              body: Center(
                child: webview,
              ));
        });
  }
}

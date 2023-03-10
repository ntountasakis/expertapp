import 'dart:io';

import 'package:expertapp/src/appbars/expert_view/expert_post_signup_appbar.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_functions.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExpertViewConnectedAccountSignupPage extends StatefulWidget {
  final String uid;

  const ExpertViewConnectedAccountSignupPage({required this.uid});

  @override
  State<ExpertViewConnectedAccountSignupPage> createState() =>
      _ExpertViewConnectedAccountSignupPageState();
}

class _ExpertViewConnectedAccountSignupPageState
    extends State<ExpertViewConnectedAccountSignupPage> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  Widget _buildWebView() {
    return WebView(
      initialUrl: HttpEndpoints.getExpertConnectedAccountSignup(widget.uid),
      javascriptMode: JavascriptMode.unrestricted,
    );
  }

  PreferredSizeWidget _buildAppbar(
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    if (snapshot.hasData) {
      return ExpertPostSignupAppbar(
        uid: widget.uid,
        titleText: 'Continue to set your availability',
        nextRoute: Routes.EV_UPDATE_AVAILABILITY_PAGE,
        addAdditionalParams: true,
        allowBackButton: false,
      );
    }
    return AppBar(
      title: const Text('Sign up for expert account'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentWrapper<PublicExpertInfo>?>(
        stream: PublicExpertInfo.getStreamForUser(widget.uid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
          return Scaffold(
              appBar: _buildAppbar(snapshot),
              body: Center(
                child: _buildWebView(),
              ));
        });
  }
}

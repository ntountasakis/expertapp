import 'dart:io';

import 'package:expertapp/src/firebase/cloud_functions/callable_functions.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up for Expert Account'),
      ),
      body: Center(
        child: _buildWebView(),
      ),
    );
  }
}

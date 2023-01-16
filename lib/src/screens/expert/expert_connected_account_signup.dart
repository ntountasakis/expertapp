import 'dart:io';

import 'package:expertapp/src/firebase/cloud_functions/callable_functions.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExpertConnectedAccountSignup extends StatefulWidget {
  final String uid;

  const ExpertConnectedAccountSignup({required this.uid});

  @override
  State<ExpertConnectedAccountSignup> createState() => _ExpertConnectedAccountSignupState();
}

class _ExpertConnectedAccountSignupState extends State<ExpertConnectedAccountSignup> {
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

import 'dart:io';

import 'package:expertapp/src/firebase/cloud_functions/callable_functions.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExpertViewStripeEarningsDashboard extends StatefulWidget {
  final String uid;

  const ExpertViewStripeEarningsDashboard({required this.uid});

  @override
  State<ExpertViewStripeEarningsDashboard> createState() =>
      _ExpertViewStripeEarningsDashboardState();
}

class _ExpertViewStripeEarningsDashboardState
    extends State<ExpertViewStripeEarningsDashboard> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  Widget _buildWebView() {
    return WebView(
      initialUrl: HttpEndpoints.getExpertStripeEarningsDashboard(widget.uid),
      javascriptMode: JavascriptMode.unrestricted,
    );
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
      title: const Text('View your earnings'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppbar(),
        body: Center(
          child: _buildWebView(),
        ));
  }
}

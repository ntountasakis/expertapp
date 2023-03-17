import 'dart:io';

import 'package:expertapp/src/firebase/cloud_functions/callable_functions.dart';
import 'package:expertapp/src/util/webview_wrapper.dart';
import 'package:flutter/material.dart';

class ExpertViewStripeEarningsDashboard extends StatelessWidget {
  final String uid;
  late final WebviewWrapper webview;

  ExpertViewStripeEarningsDashboard({required this.uid}) {
    webview = WebviewWrapper(
        initUrl: HttpEndpoints.getExpertStripeEarningsDashboard(this.uid));
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
                child: webview,
              ));
  }
}


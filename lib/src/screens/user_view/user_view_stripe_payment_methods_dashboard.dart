import 'package:expertapp/src/firebase/cloud_functions/callable_functions.dart';
import 'package:expertapp/src/util/webview_wrapper.dart';
import 'package:flutter/material.dart';

class UserViewStripeBillingDashboard extends StatelessWidget {
  final String uid;
  late final WebviewWrapper webview;

  UserViewStripeBillingDashboard({required this.uid}) {
    webview = WebviewWrapper(
        initUrl:
            HttpEndpoints.getCustomerStripePaymentMethodsDashboard(this.uid));
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
        title: FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(
        'Manage Your Payment Methods',
      ),
    ));
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

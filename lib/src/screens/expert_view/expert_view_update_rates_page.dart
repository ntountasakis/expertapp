import 'package:expertapp/src/profile/expert/expert_view_call_rates_scaffold.dart';
import 'package:flutter/material.dart';

class ExpertViewUpdateRatesPage extends StatelessWidget {
  final String uid;

  const ExpertViewUpdateRatesPage({required this.uid});

  @override
  Widget build(BuildContext context) {
    return ExpertViewCallRatesScaffold(
      uid: uid,
      fromSignupFlow: false,
      appBarBuilder: null,
    );
  }
}

import 'package:expertapp/src/profile/expert/expert_view_availability_scaffold.dart';
import 'package:flutter/material.dart';

class ExpertViewUpdateAvailabilityPage extends StatelessWidget {
  final String uid;
  late final ExpertViewUpdateAvailabilityScaffold scaffold;

  ExpertViewUpdateAvailabilityPage({required this.uid}) {
    scaffold = ExpertViewUpdateAvailabilityScaffold(
      uid: uid,
      fromSignupFlow: false,
      appBarBuilder: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold;
  }
}

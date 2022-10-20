import 'package:expertapp/main.dart';
import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/profile/expert/expert_pricing_card.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:expertapp/src/screens/navigation/expert_profile_arguments.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:expertapp/src/screens/transaction/client/call_begin_client_payment_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallClientPreview extends StatelessWidget {
  final DocumentWrapper<UserMetadata> expertUserMetadata;
  final DocumentWrapper<ExpertRate> expertRate;

  CallClientPreview(this.expertUserMetadata, this.expertRate);

  final explanationBlurbStyle = TextStyle(
    fontSize: 12,
  );
  final ButtonStyle callButtonStyle =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  String blurbText() {
    String longText =
        '''Clicking begin will begin your call with ${expertUserMetadata.documentType.firstName}.
        You will be charged at the rate listed above. At anytime you may
        end the call and will be shown a screen summarizing the charges.
        During the call you can navigate to the in-call screen that will
        show your real-time charges.
        ''';
    return longText.replaceAll('\n', '').replaceAll(RegExp(' {2,}'), ' ');
  }

  Widget buildExplanationBlurb() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Text(
        blurbText(),
        style: explanationBlurbStyle,
      ),
    );
  }

  Widget buildBeginCallButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: callButtonStyle,
        onPressed: () {
          final selectedExpert = this.expertUserMetadata;
          rootNavigatorKey.currentState!.popUntil((route) => route.isFirst);
          rootNavigatorKey.currentState!.pushNamed(
              Routes.CLIENT_CALL_PAYMENT_BEGIN,
              arguments: ExpertProfileArguments(selectedExpert));
        },
        child: const Text('Begin Call'),
      ),
    );
  }

  Widget buildPricingCard() {
    return ExpertPricingCard(expertRate.documentType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserPreviewAppbar(expertUserMetadata),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(children: [
          buildPricingCard(),
          SizedBox(
            height: 20,
          ),
          buildExplanationBlurb(),
          SizedBox(
            height: 20,
          ),
          buildBeginCallButton(context)
        ]),
      ),
    );
  }
}

import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/expert/expert_pricing_card.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CallClientPreview extends StatelessWidget {
  final String _expertUid;

  CallClientPreview(this._expertUid);

  final explanationBlurbStyle = TextStyle(
    fontSize: 12,
  );
  final ButtonStyle callButtonStyle =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  String blurbText(UserMetadata expertUserMetadata) {
    String longText =
        '''Clicking begin will begin your call with ${expertUserMetadata.firstName}.
        You will be charged at the rate listed above. At anytime you may
        end the call and will be shown a screen summarizing the charges.
        During the call you can navigate to the in-call screen that will
        show your real-time charges.
        ''';
    return longText.replaceAll('\n', '').replaceAll(RegExp(' {2,}'), ' ');
  }

  Widget buildExplanationBlurb(UserMetadata expertUserMetadata) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Text(
        blurbText(expertUserMetadata),
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
          context.goNamed(Routes.EXPERT_CALL_HOME_PAGE,
              params: {Routes.EXPERT_ID_PARAM: _expertUid});
        },
        child: const Text('Begin Call'),
      ),
    );
  }

  Widget buildPricingCard(ExpertRate rate) {
    return ExpertPricingCard(rate);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: Future.wait(
            [UserMetadata.get(_expertUid), ExpertRate.get(_expertUid)]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final expertUserMetadata =
                snapshot.data![0] as DocumentWrapper<UserMetadata>?;
            final expertRate =
                snapshot.data![1] as DocumentWrapper<ExpertRate>?;
            return Scaffold(
                appBar: UserPreviewAppbar(expertUserMetadata!, ""),
                body: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(children: [
                    buildPricingCard(expertRate!.documentType),
                    SizedBox(
                      height: 20,
                    ),
                    buildExplanationBlurb(expertUserMetadata.documentType),
                    SizedBox(
                      height: 20,
                    ),
                    buildBeginCallButton(context)
                  ]),
                ));
          } else {
            return Scaffold(
              body: CircularProgressIndicator(),
            );
          }
        });
  }
}

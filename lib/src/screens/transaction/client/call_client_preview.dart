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
    fontSize: 14,
    color: Colors.grey[800],
    fontWeight: FontWeight.w500,
  );
  final ButtonStyle callButtonStyle =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  String blurbText(UserMetadata expertUserMetadata) {
    String longText =
        '''Click begin to video call ${expertUserMetadata.firstName}.
        The call meter will stop once you or ${expertUserMetadata.firstName}
        end the call. We will charge your payment method at the next screen
        and once the call is over for the time-based charges. If ${expertUserMetadata.firstName}
        does not answer, all charges will be refunded immediately.
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
                appBar: UserPreviewAppbar(expertUserMetadata!, "Call"),
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

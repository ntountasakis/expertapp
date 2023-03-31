import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/expert/expert_pricing_card.dart';
import 'package:expertapp/src/appbars/user_view/user_preview_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserViewCallPreviewPage extends StatelessWidget {
  final String _expertUid;

  UserViewCallPreviewPage(this._expertUid);

  final explanationBlurbStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey[800],
    fontWeight: FontWeight.w500,
  );
  final ButtonStyle callButtonStyle =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  String blurbText(PublicExpertInfo publicExpertInfo) {
    String longText =
        '''Click begin to video call ${publicExpertInfo.firstName}.
        The call meter will stop once you or ${publicExpertInfo.firstName}
        end the call. We will charge your payment method at the next screen
        and once the call is over for the time-based charges. If ${publicExpertInfo.firstName}
        does not answer, all charges will be refunded immediately.
        ''';
    return longText.replaceAll('\n', '').replaceAll(RegExp(' {2,}'), ' ');
  }

  Widget buildExplanationBlurb(PublicExpertInfo publicExpertInfo) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Text(
        blurbText(publicExpertInfo),
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
          context.goNamed(Routes.UV_CALL_HOME_PAGE,
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
        future: Future.wait([
          PublicExpertInfo.get(_expertUid),
          ExpertRate.get(_expertUid),
          PublicUserInfo.get(_expertUid)
        ]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final publicExpertInfo =
                snapshot.data![0] as DocumentWrapper<PublicExpertInfo>?;
            final expertRate =
                snapshot.data![1] as DocumentWrapper<ExpertRate>?;
            final publicUserInfo =
                snapshot.data![2] as DocumentWrapper<PublicUserInfo>?;
            return Scaffold(
                appBar: UserPreviewAppbar(publicUserInfo!.documentType.firstName, "Call"),
                body: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(children: [
                    buildPricingCard(expertRate!.documentType),
                    SizedBox(
                      height: 20,
                    ),
                    buildExplanationBlurb(publicExpertInfo!.documentType),
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

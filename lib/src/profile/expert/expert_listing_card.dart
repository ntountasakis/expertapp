import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/expert/expert_rating.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertListingCard extends StatelessWidget {
  final DocumentWrapper<PublicExpertInfo> _publicExpertInfo;

  const ExpertListingCard(this._publicExpertInfo);

  Widget buildLeading(BuildContext context) {
    final TextStyle nameStyle =
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    return Column(
      children: [
        Text(
          _publicExpertInfo.documentType.shortName(),
          style: nameStyle,
        ),
        SizedBox(
          height: 40,
          width: 40,
          child: ProfilePicture(_publicExpertInfo.documentType.profilePicUrl),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }

  Widget buildTitle() {
    final TextStyle categoryStyle =
        TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    return Column(
      children: [
        Text(
          _publicExpertInfo.documentType.majorCategory() +
              " - " +
              _publicExpertInfo.documentType.minorCategory(),
          style: categoryStyle,
        ),
        SizedBox(height: 5),
        Row(
          children: [
            buildStarRating(_publicExpertInfo, 16),
            SizedBox(width: 5),
            buildTextRating(_publicExpertInfo, 16),
          ],
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Widget buildTrailing() {
    final TextStyle rateStyle =
        TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
    return FutureBuilder(
        future: ExpertRate.get(_publicExpertInfo.documentId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<ExpertRate>?> snapshot) {
          if (snapshot.hasData) {
            final rate = snapshot.data as DocumentWrapper<ExpertRate>;
            return Column(
              children: [
                Text(
                  "Start fee: " + rate.documentType.formattedStartCallFee(),
                  style: rateStyle,
                ),
                Text(
                  "Per minute fee: " +
                      rate.documentType.formattedPerMinuteFee(),
                  style: rateStyle,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            );
          }
          return SizedBox();
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(Routes.UV_EXPERT_PROFILE_PAGE,
            params: {Routes.EXPERT_ID_PARAM: _publicExpertInfo.documentId});
      },
      child: Card(
        child: ListTile(
          leading: buildLeading(context),
          title: buildTitle(),
          trailing: buildTrailing(),
        ),
      ),
    );
  }
}

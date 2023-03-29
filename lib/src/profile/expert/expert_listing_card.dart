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
    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IntrinsicWidth(
            child: Text(
              _publicExpertInfo.documentType.shortName(),
              style: nameStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: ProfilePicture(_publicExpertInfo.documentType.profilePicUrl),
          ),
        ],
      ),
    );
  }

  Widget buildTitle() {
    final TextStyle categoryStyle =
        TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
    return Text(
      _publicExpertInfo.documentType.majorCategory(),
      style: categoryStyle,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildSubtitle() {
    final TextStyle categoryStyle =
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicWidth(
          child: Text(
            _publicExpertInfo.documentType.minorCategory(),
            style: categoryStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 5),
        buildStarRating(_publicExpertInfo, 14),
      ],
    );
  }

  Widget buildTrailing() {
    final TextStyle rateStyle =
        TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
    return FutureBuilder(
        future: ExpertRate.get(_publicExpertInfo.documentId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<ExpertRate>?> snapshot) {
          if (snapshot.hasData) {
            final rate = snapshot.data as DocumentWrapper<ExpertRate>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      child: Container(
        height: 100,
        child: Card(
          child: ListTile(
            dense: true,
            visualDensity: VisualDensity(
                horizontal: VisualDensity.maximumDensity,
                vertical: VisualDensity.maximumDensity),
            leading: buildLeading(context),
            title: buildTitle(),
            subtitle: buildSubtitle(),
            trailing: buildTrailing(),
          ),
        ),
      ),
    );
  }
}

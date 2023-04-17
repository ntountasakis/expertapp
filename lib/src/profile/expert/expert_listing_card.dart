import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/profile_leading_tile.dart';
import 'package:expertapp/src/profile/expert/expert_rating.dart';
import 'package:expertapp/src/util/tappable_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertListingCard extends StatelessWidget {
  final DocumentWrapper<PublicExpertInfo> _publicExpertInfo;

  const ExpertListingCard(this._publicExpertInfo, {Key? key}) : super(key: key);

  Widget buildTitle() {
    final TextStyle majorStyle =
        TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
    final TextStyle minorStyle = TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600]);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _publicExpertInfo.documentType.majorCategory(),
          style: majorStyle,
          overflow: TextOverflow.ellipsis,
        ),
        IntrinsicWidth(
          child: Text(
            _publicExpertInfo.documentType.minorCategory(),
            style: minorStyle,
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
    return buildTappableCard(
        context: context,
        leading: buildLeadingProfileTile(
            context: context,
            shortName: _publicExpertInfo.documentType.shortName(),
            profilePicUrl: _publicExpertInfo.documentType.profilePicUrl,
            showOnlineStatus: true,
            isOnline: _publicExpertInfo.documentType.isOnline),
        title: buildTitle(),
        subtitle: SizedBox(),
        trailing: buildTrailing(),
        onTapCallback: (BuildContext context) {
          context.pushNamed(Routes.UV_EXPERT_PROFILE_PAGE,
              params: {Routes.EXPERT_ID_PARAM: _publicExpertInfo.documentId});
        });
  }
}

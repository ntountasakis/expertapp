import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/text_rating.dart';
import 'package:flutter/material.dart';

import '../star_rating.dart';

Widget buildStarRating(
    DocumentWrapper<PublicExpertInfo> publicExpertInfo, double size) {
  return FittedBox(
      fit: BoxFit.fitWidth,
      child: StarRating(
          publicExpertInfo.documentType.getAverageReviewRating(), size));
}

Widget buildTextRating(
    DocumentWrapper<PublicExpertInfo> publicExpertInfo, double size) {
  return TextRating(
      publicExpertInfo.documentType.getAverageReviewRating(), size);
}

Widget buildExpertProfileRating(
    DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
  return Row(
    children: [
      Flexible(flex: 20, child: buildStarRating(publicExpertInfo, 25)),
      Spacer(flex: 1),
      Flexible(flex: 20, child: buildTextRating(publicExpertInfo, 18))
    ],
  );
}

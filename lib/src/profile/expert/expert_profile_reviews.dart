import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_reviews.dart';
import 'package:flutter/material.dart';

Widget buildExpertProfileReviewList(
    DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
  return Expanded(
    child: ExpertReviews(publicExpertInfo),
  );
}

Widget buildExpertProfileReviewHeading() {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          "Customer Reviews",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Spacer()
    ],
  );
}

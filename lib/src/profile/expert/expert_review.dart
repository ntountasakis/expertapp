import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/firebase/firestore/document_models/review.dart';
import 'package:flutter/material.dart';
import 'package:expertapp/src/profile/star_rating.dart';

class ExpertReview extends StatelessWidget {
  final DocumentWrapper<PublicUserInfo> _reviewerUserMetadata;
  final DocumentWrapper<Review> _expertReview;

  ExpertReview(this._reviewerUserMetadata, this._expertReview);

  // todo bug, this should use name of reviewer,
  static Stream<Iterable<Widget>> getStream(String expertUserUid) {
    return Review.getStream(expertUserUid)
        .map((Iterable<DocumentWrapper<Review>> iterableReviews) {
      return iterableReviews.map((DocumentWrapper<Review> wrappedReview) {
        return FutureBuilder(
            future: PublicUserInfo.get(wrappedReview.documentType.authorUid),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentWrapper<PublicUserInfo>?> snapshot) {
              if (snapshot.hasData) {
                return ExpertReview(snapshot.data!, wrappedReview);
              } else {
                return CircularProgressIndicator();
              }
            });
      });
    });
  }

  static Widget buildReviewCard(
      String firstName, String reviewText, double rating) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(children: [
          Row(children: [
            Text(firstName, style: TextStyle(fontSize: 16)),
            SizedBox(width: 10),
            StarRating(rating, 16.0)
          ]),
          Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    reviewText,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildReviewCard(
        _reviewerUserMetadata.documentType.firstName,
        _expertReview.documentType.reviewText,
        _expertReview.documentType.rating);
  }
}

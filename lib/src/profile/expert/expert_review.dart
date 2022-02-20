import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/review.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_information.dart';
import 'package:flutter/material.dart';
import 'package:expertapp/src/profile/star_rating.dart';

class ExpertReview extends StatelessWidget {
  final DocumentWrapper<UserInformation> _reviewerUserInfo;
  final DocumentWrapper<Review> _expertReview;

  ExpertReview(this._reviewerUserInfo, this._expertReview);

  static Stream<Iterable<ExpertReview>> getStream(
      DocumentWrapper<UserInformation> expertUser) {
    return Review.getStream(expertUser.documentType.authUid)
        .map((Iterable<DocumentWrapper<Review>> iterableReviews) {
      return iterableReviews.map((DocumentWrapper<Review> wrappedReview) {
        return ExpertReview(expertUser, wrappedReview);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        padding: EdgeInsets.all(0.0),
        margin: EdgeInsets.all(0.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(children: [
              Row(children: [
                Wrap(
                    spacing: 8.0,
                    alignment: WrapAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Text(_reviewerUserInfo.documentType.firstName,
                          style: TextStyle(fontSize: 16)),
                      StarRating(_expertReview.documentType.rating, 16.0)
                    ])
              ]),
              Expanded(
                  child: Scrollbar(
                child: SingleChildScrollView(
                  child: Text(_expertReview.documentType.reviewText),
                ),
              )),
            ]),
          ),
        ));
  }
}

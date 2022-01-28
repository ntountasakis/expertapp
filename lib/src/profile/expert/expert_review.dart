import 'package:expertapp/src/firebase/database/models/review.dart';
import 'package:expertapp/src/firebase/database/models/user_information.dart';
import 'package:flutter/material.dart';
import 'package:expertapp/src/profile/star_rating.dart';

class ExpertReview extends StatelessWidget {
  final Review _expertReview;
  final UserInformation _reviewerUserInfo;

  ExpertReview(this._expertReview, this._reviewerUserInfo);

  static Stream<List<ExpertReview>> getStream(
      UserInformation expertUser) {
    return Review.getStream(expertUser.uid).map((List<Review> reviews) {
      final List<ExpertReview> myReviewWidgets = [];

      reviews.forEach((Review review) async {
        UserInformation? reviewerInfo = await UserInformation.get(review.reviewerUid);
        if (reviewerInfo != null)
        {
          myReviewWidgets.add(ExpertReview(review, reviewerInfo));
        }
      });

      return myReviewWidgets;
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
                      Text(_reviewerUserInfo.firstName,
                          style: TextStyle(fontSize: 16)),
                      StarRating(_expertReview.rating, 16.0)
                    ])
              ]),
              Expanded(
                  child: Scrollbar(
                      child: SingleChildScrollView(
                          child: Text(_expertReview.review))))
            ]),
          ),
        ));
  }
}

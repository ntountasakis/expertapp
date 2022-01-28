import 'package:expertapp/src/firebase/database/models/review.dart';
import 'package:expertapp/src/firebase/database/models/user_information.dart';
import 'package:expertapp/src/profile/expert/expert_review.dart';
import 'package:flutter/material.dart';

class ExpertReviews extends StatefulWidget {
  final UserInformation _expertUserInfo;
  const ExpertReviews(this._expertUserInfo);

  @override
  State<ExpertReviews> createState() => _ExpertReviewsState();
}

class _ExpertReviewsState extends State<ExpertReviews> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ExpertReview.getStream(widget._expertUserInfo),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final myReviews =
                List<ExpertReview>.from(snapshot.data! as List<ExpertReview>);
            return ListView.builder(
                itemCount: myReviews.length,
                itemBuilder: (context, index) {
                  return myReviews[index];
                });
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

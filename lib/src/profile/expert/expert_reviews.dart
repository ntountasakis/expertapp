import 'package:expertapp/src/firebase/database/expert_review_loader.dart';
import 'package:expertapp/src/firebase/database/models/user_id.dart';
import 'package:expertapp/src/profile/expert/expert_review.dart';
import 'package:flutter/material.dart';

class ExpertReviews extends StatefulWidget {
  final UserId _userId;
  const ExpertReviews(this._userId);

  @override
  State<ExpertReviews> createState() => _ExpertReviewsState();
}

class _ExpertReviewsState extends State<ExpertReviews> {
  final _expertReviewLoader = ExpertReviewLoader();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _expertReviewLoader.getExpertReviewStream(widget._userId),
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

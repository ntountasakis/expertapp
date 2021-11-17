import 'package:expertapp/src/profile/expert/expert_review.dart';
import 'package:flutter/material.dart';

import '../../database/expert_review_loader.dart';

class ExpertReviews extends StatefulWidget {
  @override
  State<ExpertReviews> createState() => _ExpertReviewsState();
}

class _ExpertReviewsState extends State<ExpertReviews> {
  final _expertReviewLoader = ExpertReviewLoader();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _expertReviewLoader.getExpertReviewStream(),
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

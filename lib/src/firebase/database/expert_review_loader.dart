import 'package:expertapp/src/profile/expert/expert_review.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

import 'database_paths.dart';
import 'models/user_id.dart';

class ExpertReviewLoader {
  final _database = FirebaseDatabase.instance.ref();

  Stream<List<ExpertReview>> getExpertReviewStream(UserId aExpertUser) {
    final reviewStream = _database
        .child(DatabasePaths.EXPERT_REVIEWS_FOR_EXPERT(aExpertUser))
        .onValue;
    final reviewStreamToPublish = reviewStream.map((event) {
      final reviewMap = Map<String, dynamic>.from(event.snapshot.value as Map<String, dynamic>);
      List<ExpertReview> expertReviews = [];
      for (var expertReviewerName in reviewMap.keys) {
        var nextReview = Map<String, dynamic>.from(reviewMap[expertReviewerName]);
        try {
          var myExpertReview =
              ExpertReview.fromRTDB(expertReviewerName, nextReview);
          expertReviews.add(myExpertReview);
        } catch (e) {
          log(e.toString());
        }
      }
      return expertReviews;
    });
    return reviewStreamToPublish;
  }
}

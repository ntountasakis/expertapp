import 'dart:convert';

import 'package:expertapp/src/profile/expert/expert_review.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

class ExpertReviewLoader {
  final _database = FirebaseDatabase.instance.reference();

  Stream<List<ExpertReview>> getExpertReviewStream() {
    final reviewStream = _database.child('expertReviews/expertReviews').onValue;
    final reviewStreamToPublish = reviewStream.map((event) {
      final reviewMap = Map<String, dynamic>.from(event.snapshot.value);
      List<ExpertReview> expertReviews = [];
      for (var expertReview in reviewMap.keys) {
        var thisExpertsReviews =
            Map<String, dynamic>.from(reviewMap[expertReview]);
        for (var reviewer in thisExpertsReviews.keys) {
          var theirReview =
              Map<String, dynamic>.from(thisExpertsReviews[reviewer]);
          var myExpertReview;
          try {
            myExpertReview = ExpertReview.fromRTDB(reviewer, theirReview);
          } catch (e) {
            log(e.toString());
          }
          expertReviews.add(myExpertReview);
        }
      }
      return expertReviews;
    });
    return reviewStreamToPublish;
  }
}

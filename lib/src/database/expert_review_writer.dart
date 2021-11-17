import 'dart:convert';
import 'dart:developer';

import 'package:expertapp/src/profile/expert/expert_review.dart';
import 'package:firebase_database/firebase_database.dart';

class ExpertReviewWriter {
  final _database = FirebaseDatabase.instance.reference();

  void uploadReview(ExpertReview aExpertReview) {
    final _reviewRef = _database.child('expertReviews/expertReviews/John Doe');

    final myJsonPayload = jsonEncode(aExpertReview.makeMap());
    log('json payload: $myJsonPayload');

    _reviewRef.set(aExpertReview.makeMap());
  }
}

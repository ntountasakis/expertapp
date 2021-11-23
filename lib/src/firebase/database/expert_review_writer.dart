import 'package:expertapp/src/profile/expert/expert_review.dart';
import 'package:firebase_database/firebase_database.dart';

import 'database_paths.dart';
import 'models/user_id.dart';

class ExpertReviewWriter {
  final _database = FirebaseDatabase.instance.reference();

  void uploadReview(UserId aExpertUser, ExpertReview aExpertReview) {
    final _reviewRef = _database.child(DatabasePaths.EXPERT_REVIEWS_FOR_EXPERT(aExpertUser));
    _reviewRef.set(aExpertReview.makeMap());
  }
}

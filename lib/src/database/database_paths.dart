import 'package:expertapp/src/database/models/user_id.dart';

class DatabasePaths {
  static const EXPERT_USERS = 'expertUsers/';
  static const EXPERT_REVIEWS = 'expertReviews/';

  static EXPERT_REVIEWS_FOR_EXPERT(UserId userId) {
    return EXPERT_REVIEWS + userId.id + '/';
  }
}

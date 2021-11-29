import 'models/user_id.dart';

class DatabasePaths {
  static const EXPERT_USERS = 'expertUsers/';
  static const EXPERT_REVIEWS = 'expertReviews/';
  static const PROFILE_PIC_URLS = 'profilePicURLs/';

  static EXPERT_REVIEWS_FOR_EXPERT(UserId userId) {
    return EXPERT_REVIEWS + userId.id + '/';
  }

  static PROFILE_PIC_FOR_EXPERT(UserId userId) {
    return PROFILE_PIC_URLS + userId.id + '/';
  }
}

class DatabasePaths {
  static const EXPERT_REVIEWS = 'expertReviews/';
  static const PROFILE_PIC_URLS = 'profilePicURLs/';
  static const USER_INFO = 'userInfo/';

  static PROFILE_PIC_FOR_EXPERT(String uid) {
    return PROFILE_PIC_URLS + uid + '/';
  }
}

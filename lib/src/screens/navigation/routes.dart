class Routes {
  static const HOME = '/';

  static const SIGN_IN_PREFIX = '/signin';
  static const SIGN_IN_START = '$SIGN_IN_PREFIX:start';
  static const SIGN_IN_AUTH = '$SIGN_IN_PREFIX:auth';
  static const SIGN_IN_USER_CREATE = '$SIGN_IN_PREFIX:user_create';

  static const EXPERT_LISTINGS = '/expertlistings';
  static const EXPERT_PROFILE_PAGE = '$EXPERT_LISTINGS/expertProfilePage';
  static const EXPERT_CALL_PREVIEW = '$EXPERT_LISTINGS/expertCallPreview';

  static const CLIENT_CALL_PREFIX = '/clientcall';
  static const CLIENT_CALL_PAYMENT_BEGIN = '$CLIENT_CALL_PREFIX:paymentbegin';
  static const CLIENT_CALL_MAIN = '$CLIENT_CALL_PREFIX:main';
  static const CLIENT_CALL_CHAT = '$CLIENT_CALL_PREFIX:chat?room_id=';
  static const CLIENT_CALL_PAYMENT_END = '$CLIENT_CALL_PREFIX:paymentEnd';
  static const CLIENT_CALL_SUMMARY = '$CLIENT_CALL_PREFIX:summary';
}

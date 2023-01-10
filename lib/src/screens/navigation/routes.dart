class Routes {
  static const HOME = '/';

  static const SIGN_IN_PAGE = '/signin';
  static const USER_CREATE_PAGE = '/usercreate';

  static const USER_PROFILE_PAGE = '/userprofilepage';
  static const USER_COMPLETED_CALLS = '/usercompletedcalls';

  static const AGORA_CHANNEL_NAME_PARAM = 'channelName';
  static const AGORA_TOKEN_PARAM = 'token';
  static const AGORA_UID_PARAM = 'uid';
  static const CALLED_UID_PARAM = 'calledUid';
  static const CALLER_UID_PARAM = 'callerUid';
  static const CALL_TRANSACTION_ID_PARAM = 'callTransactionId';
  static const EXPERT_ID_PARAM = 'id';
  static const CALL_RATE_START_PARAM = 'callRateStart';
  static const CALL_RATE_PER_MINUTE_PARAM = 'callRatePerMinute';
  static const CALL_JOIN_EXPIRATION_TIME_UTC_MS = 'callJoinExpirationTimeUtcMs';

  static const EXPERT_LISTINGS_PAGE = '/expertlistings';
  static const EXPERT_PROFILE_PAGE = 'expertProfilePage';
  static const EXPERT_CALL_PREVIEW_PAGE = 'expertCallPreview';

  static const EXPERT_CALL_HOME_PAGE = '/expertCallHome';
  static const EXPERT_CALL_CHAT_PAGE = 'expertCallChatPage';
  static const EXPERT_CALL_VIDEO_PAGE = 'expertCallVideoPage';
  static const EXPERT_REVIEW_SUBMIT_PAGE = '/expertReviewSubmitPage';
  static const EXPERT_CALL_SUMMARY_PAGE = '/expertClientSummaryPage';

  static const CALL_JOIN_PROMPT_PAGE = '/calljoinprompt';

  static const CLIENT_CALL_HOME = '/clientCallHome';
  static const CLIENT_CALL_CHAT_PAGE = 'clientCallChatPage';
  static const CLIENT_CALL_VIDEO_PAGE = 'clientCallVideoPage';
  static const CLIENT_SUMMARY_PAGE = '/clientCallSummaryPage';

  static String chatroomId(String aRoute) {
    final split = aRoute.split('?');
    if (split.length != 2) {
      throw new Exception("Cannot parse chatroom id: ${aRoute}");
    }
    return split[1];
  }
}

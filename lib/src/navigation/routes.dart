class Routes {
  // PAGES

  // common pages
  static const HOME_PAGE = '/';
  static const ONBOARDING = '/onboarding';
  static const SIGN_IN_PAGE = '/signin';
  static const DELETE_ACCOUNT_PAGE = '/deleteaccount';

  // user view pages
  static const UV_USER_SIGNUP_PAGE = '/uv_user_signup';
  static const UV_COMPLETED_CALLS_PAGE = '/uv_completedcalls';
  static const UV_EXPERT_PROFILE_PAGE = 'uv_expertprofile';
  static const UV_EXPERT_CALL_PREVIEW_PAGE = 'uv_callpreview';
  static const UV_CALL_HOME_PAGE = '/uv_callhome';
  static const UV_CALL_CHAT_PAGE = 'uv_callchat';
  static const UV_CALL_VIDEO_PAGE = 'uv_callvideo';
  static const UV_REVIEW_SUBMIT_PAGE = '/uv_submitreview';
  static const UV_VIEW_EXPERT_AVAILABILITY_PAGE = '/uv_viewexpertavailability';
  static const UV_CALL_SUMMARY_PAGE = '/uv_callsummary';
  static const UV_PAST_CHATS = '/uv_pastchats';
  static const UV_STRIPE_PAYMENT_METHODS_DASHBOARD =
      '/uv_stripebillingdashboard';

  // expert-only pages
  static const EV_PROFILE_EDIT_PAGE = '/ev_profileedit';
  static const EV_UPDATE_AVAILABILITY_PAGE = '/ev_updateavailability';
  static const EV_UPDATE_RATE_PAGE = '/ev_updaterates';
  static const EV_CONNECTED_ACCOUNT_SIGNUP_PAGE = '/ev_connectedaccountsignup';
  static const EV_COMPLETED_CALLS_PAGE = '/ev_completedcalls';
  static const EV_CALL_JOIN_PROMPT_PAGE = '/ev_calljoinprompt';
  static const EV_CALL_HOME_PAGE = '/ev_callhome';
  static const EV_CALL_CHAT_PAGE = 'ev_callchat';
  static const EV_CALL_VIDEO_PAGE = 'ev_callvideo';
  static const EV_CALL_SUMMARY_PAGE = '/ev_callsummary';
  static const EV_STRIPE_EARNINGS_DASHBOARD = '/ev_stripeearningsdashboard';
  static const EV_PAST_CHATS = '/ev_pastchats';

  // PARAMETERS
  static const AGORA_CHANNEL_NAME_PARAM = 'channelname';
  static const AGORA_TOKEN_PARAM = 'token';
  static const AGORA_UID_PARAM = 'uid';
  static const CALLED_UID_PARAM = 'calleduid';
  static const CALLER_UID_PARAM = 'calleruid';
  static const CALL_TRANSACTION_ID_PARAM = 'calltransactionid';
  static const EXPERT_ID_PARAM = 'id';
  static const IS_EDITABLE_PARAM = 'isEditable';
  static const CALL_RATE_START_PARAM = 'callratestart';
  static const CALL_RATE_PER_MINUTE_PARAM = 'callrateperminute';
  static const CALL_JOIN_EXPIRATION_TIME_UTC_MS_PARAM =
      'calljoinexpirationtimeutcMs';
  static const FROM_EXPERT_SIGNUP_FLOW_PARAM = 'fromexpertsignupflow';

  static String chatroomId(String aRoute) {
    final split = aRoute.split('?');
    if (split.length != 2) {
      throw new Exception("Cannot parse chatroom id: ${aRoute}");
    }
    return split[1];
  }
}

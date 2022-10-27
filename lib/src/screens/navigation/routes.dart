class Routes {
  static const HOME = '/';

  static const SIGN_IN_PAGE = '/signin';
  static const USER_CREATE_PAGE = '/usercreate';

  static const EXPERT_LISTINGS_PAGE = '/expertlistings';
  static const EXPERT_PROFILE_PAGE = 'expertProfilePage';
  static const EXPERT_ID_PARAM = 'id';
  static const EXPERT_CALL_PREVIEW_PAGE = 'expertCallPreview';

  static const EXPERT_CALL_HOME_PAGE = '/expertCallHome';
  static const EXPERT_CALL_CHAT_PAGE = 'expertCallChatPage';
  static const EXPERT_CALL_VIDEO_PAGE = 'expertCallVideoPage';
  static const AGORA_CHANNEL_NAME_PARM = 'channelName';
  static const AGORA_TOKEN_PARM = 'token';
  static const AGORA_UID = 'uid';


  static String chatroomId(String aRoute) {
    final split = aRoute.split('?');
    if (split.length != 2) {
      throw new Exception("Cannot parse chatroom id: ${aRoute}");
    }
    return split[1];
  }
}

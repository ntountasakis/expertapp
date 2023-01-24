import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:expertapp/src/environment/environment_config.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';

class CallableFunctions {
  static final String USER_SIGNUP = 'userSignup';
  static final String SUBMIT_REVIEW = 'submitReview';
  static final String UPDATE_PROFILE_PIC = 'updateProfilePicture';
  static final String UPDATE_PROFILE_DESCRIPTION = 'updateProfileDescription';
  static final String CHATROOM_LOOKUP = 'chatroomLookup';
  static final String UPDATE_EXPERT_RATE = 'updateExpertRate';
}

class HttpEndpoints {
  static String getCloudFunctionsBaseUrl() {
    final region = FirebaseFunctions.instance.delegate.region;
    final projectId = FirebaseFunctions.instance.app.options.projectId;

    if (EnvironmentConfig.getConfig().isProd()) {
      return 'https://' + region + '-' + projectId + '.cloudfunctions.net/';
    }
    return 'http://' +
        localhostString() +
        ':9001/' +
        projectId +
        '/' +
        region +
        '/';
  }

  static String getExpertConnectedAccountSignup(String uid) {
    final url =
        getCloudFunctionsBaseUrl() + 'stripeAccountLinkRefresh?uid=$uid';
    log("Navigating to : " + url);
    return url;
  }
}

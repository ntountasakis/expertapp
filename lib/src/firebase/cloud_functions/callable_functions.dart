import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:expertapp/src/environment/environment_config.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/version/app_version.dart';

class CallableFunctions {
  static final String DELETE_USER = 'deleteUser';
  static final String REGULAR_USER_SIGNUP = 'regularUserSignup';
  static final String SUBMIT_REVIEW = 'submitReview';
  static final String UPDATE_PROFILE_PIC = 'updateProfilePicture';
  static final String UPDATE_PROFILE_DESCRIPTION = 'updateProfileDescription';
  static final String CHATROOM_LOOKUP = 'chatroomLookup';
  static final String UPDATE_EXPERT_RATE = 'updateExpertRate';
  static final String UPDATE_EXPERT_AVAILABILITY = 'updateExpertAvailability';
  static final String UPDATE_EXPERT_CATEGORY = 'updateExpertCategory';
  static final String UPDATE_EXPERT_PHONE_NUMBER = 'updateExpertPhoneNumber';
  static final String GET_ALL_CHATROOM_PREVIEWS_FOR_USER =
      'getAllChatroomPreviewsForUser';
  static final String GET_DEFAULT_PROFILE_PIC_URL = 'getDefaultProfilePicUrl';
  static final String GET_SHAREABLE_DYNAMIC_PROFILE_LINK =
      'generateExpertProfileDynamicLink';
  static final String COMPLETE_EXPERT_SIGN_UP = 'completeExpertSignUp';
  static final String GET_PLATFORM_FEE = 'getPlatformFee';
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
        getCloudFunctionsBaseUrl() + 'stripeAccountLinkRefresh?uid=${uid}&version=${AppVersion.version}';
    log("Navigating to : " + url);
    return url;
  }

  static String getExpertStripeEarningsDashboard(String uid) {
    final url = getCloudFunctionsBaseUrl() +
        'stripeConnectedAccountDashboardLinkRequest?uid=${uid}&version=${AppVersion.version}';
    log("Navigating to : " + url);
    return url;
  }

  static String getCustomerStripePaymentMethodsDashboard(String uid) {
    final url = getCloudFunctionsBaseUrl() +
        'stripeManagePaymentMethodsLinkRequest?uid=${uid}&version=${AppVersion.version}';
    log("Navigating to : " + url);
    return url;
  }
}

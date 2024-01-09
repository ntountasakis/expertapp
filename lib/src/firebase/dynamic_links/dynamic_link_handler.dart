import 'package:expertapp/src/navigation/routes.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> handleFirebaseDynamicLinkInitialLink(
    GlobalKey<NavigatorState> navigatorKey) async {
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  if (initialLink != null) {
    final Uri dynamicLink = initialLink.link;
    processDynamicLink(navigatorKey, dynamicLink);
  }
}

void listenForFirebaseDynamicLinks(GlobalKey<NavigatorState> navigatorKey) {
  FirebaseDynamicLinks.instance.onLink.listen(
    (pendingDynamicLinkData) {
      // Set up the `onLink` event listener next as it may be received here
      final Uri dynamicLink = pendingDynamicLinkData.link;
      processDynamicLink(navigatorKey, dynamicLink);
    },
  ).onError((error) {
    // Handle errors
  });
}

void processDynamicLink(
    GlobalKey<NavigatorState> navigatorKey, Uri dynamicLink) {
  if (dynamicLink.hasQuery) {
    final params = dynamicLink.queryParameters;
    if (params.containsKey('expertLinkType')) {
      final linkType = params['expertLinkType'];
      if (linkType != null) {
        if (linkType == "visitProfile") {
          processExpertProfileVisitDynamicLink(navigatorKey, dynamicLink);
        } else if (linkType == "callNotification") {
          processExpertProfileIncomingCallNotificationDynamicLink(
              navigatorKey, dynamicLink);
        }
      }
    }
  }
}

void processExpertProfileVisitDynamicLink(
    GlobalKey<NavigatorState> navigatorKey, Uri dynamicLink) {
  final params = dynamicLink.queryParameters;
  final expertUid = params['expertUid'];
  if (expertUid != null) {
    navigatorKey.currentContext!.pushNamed(Routes.UV_EXPERT_PROFILE_PAGE,
        pathParameters: {Routes.EXPERT_ID_PARAM: expertUid});
  }
}

void processExpertProfileIncomingCallNotificationDynamicLink(
    GlobalKey<NavigatorState> navigatorKey, Uri dynamicLink) {
  final params = dynamicLink.queryParameters;
  final expertUid = params['expertUid'];
  final callerUid = params["callerUid"];
  final callTransactionId = params["callTransactionId"];
  final callRateStartCents = params["callRateStartCents"];
  final callRatePerMinuteCents = params["callRatePerMinuteCents"];
  final callJoinExpirationTimeUtcMs = params["callJoinExpirationTimeUtcMs"];
  if (expertUid != null &&
      callerUid != null &&
      callTransactionId != null &&
      callRateStartCents != null &&
      callRatePerMinuteCents != null &&
      callJoinExpirationTimeUtcMs != null) {
    navigatorKey.currentContext!
        .goNamed(Routes.EV_CALL_JOIN_PROMPT_PAGE, pathParameters: {
      Routes.CALLED_UID_PARAM: expertUid,
      Routes.CALLER_UID_PARAM: callerUid,
      Routes.CALL_TRANSACTION_ID_PARAM: callTransactionId,
      Routes.CALL_RATE_START_PARAM: callRateStartCents,
      Routes.CALL_RATE_PER_MINUTE_PARAM: callRatePerMinuteCents,
      Routes.CALL_JOIN_EXPIRATION_TIME_UTC_MS_PARAM:
          callJoinExpirationTimeUtcMs,
    });
  }
}

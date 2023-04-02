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
    if (params.containsKey('expertProfile')) {
      final expertUid = params['expertProfile'];
      if (expertUid != null) {
        navigatorKey.currentContext!.pushNamed(Routes.UV_EXPERT_PROFILE_PAGE,
            params: {Routes.EXPERT_ID_PARAM: expertUid});
      }
    }
  }
}

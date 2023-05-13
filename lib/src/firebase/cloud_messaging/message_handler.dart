import 'dart:developer';

import 'package:expertapp/src/firebase/cloud_messaging/message_decoder.dart';
import 'package:expertapp/src/firebase/cloud_messaging/messages/call_join_request.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void initFirebaseMessagingOpenedApp(
    GlobalKey<NavigatorState> navigatorKey, AppLifecycle lifecycle) {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print("Handling a message that opens the app: ${message.messageId}");
    await handleMessage(navigatorKey, lifecycle, message);
  });
}

void initFirebaseMessagingForegroundHandler(
    GlobalKey<NavigatorState> navigatorKey, AppLifecycle lifecycle) {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("Handling a message in the foreground: ${message.messageId}");
    await handleMessage(navigatorKey, lifecycle, message);
  });
}

Future<void> handleMessage(GlobalKey<NavigatorState> navigatorKey,
    AppLifecycle lifecycle, RemoteMessage message) async {
  print('Message data: ${message.data}');
  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
  final messageType = message.data['messageType'];

  if (messageType == "call_join_cancel") {
    navigatorKey.currentContext!.goNamed(Routes.HOME_PAGE);
  } else if (messageType == "call_join_request") {
    final CallJoinRequestTokenPayload callJoinRequest =
        MessageDecoder.callJoinRequestFromJson(message.data);
    final DocumentWrapper<PublicUserInfo>? userInfo =
        await PublicUserInfo.get(callJoinRequest.callerUid);

    if (userInfo == null) {
      log("Cannot accept call join request from unknown user: ${callJoinRequest.callerUid}");
      return;
    }
    if (lifecycle.currentUserId() == null) {
      log("Need to suppress call join, user isnt logged in");
      return;
    }
    if (lifecycle.currentUserId()! != callJoinRequest.calledUid) {
      log("Received call join request for user that isnt me");
      return;
    }
    navigatorKey.currentContext!
        .goNamed(Routes.EV_CALL_JOIN_PROMPT_PAGE, pathParameters: {
      Routes.CALLED_UID_PARAM: callJoinRequest.calledUid,
      Routes.CALLER_UID_PARAM: callJoinRequest.callerUid,
      Routes.CALL_TRANSACTION_ID_PARAM: callJoinRequest.callTransactionId,
      Routes.CALL_RATE_START_PARAM: callJoinRequest.callRateStartCents,
      Routes.CALL_RATE_PER_MINUTE_PARAM: callJoinRequest.callRatePerMinuteCents,
      Routes.CALL_JOIN_EXPIRATION_TIME_UTC_MS_PARAM:
          callJoinRequest.callJoinExpirationTimeUtcMs,
    });
  }
}

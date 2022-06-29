import 'dart:developer';

import 'package:expertapp/main.dart';
import 'package:expertapp/src/firebase/cloud_messaging/message_decoder.dart';
import 'package:expertapp/src/firebase/cloud_messaging/messages/call_join_request.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/transaction/expert_call_join_prompt.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void initFirebaseMessagingOpenedApp() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Handling a notification click: ${message.messageId}");

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
}

void initFirebaseMessagingForegroundHandler() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }

    final CallJoinRequest request =
        MessageDecoder.callJoinRequestFromJson(message.data);
    final DocumentWrapper<UserMetadata>? callerMetadata =
        await UserMetadata.get(request.callerUid);

    if (callerMetadata == null) {
      log("Cannot accept call join request from unknown user: ${request.callerUid}");
      return;
    }
    navigatorKey.currentState?.push(
      MaterialPageRoute(
      builder: (context) => ExpertCallJoinPrompt(
        request,
        callerMetadata,
      ),
    ));
  });
}

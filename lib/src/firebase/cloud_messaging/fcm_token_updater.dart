import 'dart:developer';

import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/fcm_token.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmTokenUpdater {
  final Stream<String> _tokenStream;

  FcmTokenUpdater() : _tokenStream = FirebaseMessaging.instance.onTokenRefresh;

  void putCurrentToken(DocumentWrapper<PublicUserInfo> userInfo) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      throw Exception("Unexpected null fcm token");
    }
    log("Current FCM token ${fcmToken}");
    await putToken(userInfo.documentId, fcmToken);
  }

  void updateTokensOnRefresh(DocumentWrapper<PublicUserInfo> userInfo) {
    _tokenStream.listen((fcmToken) async {
      log("FCM token refreshed: ${fcmToken}");
      await putToken(userInfo.documentId, fcmToken);
    }).onError((err) {
      log("FCM token refresh error: ${err}");
    });
  }

  Future<void> putToken(String documentId, String token) async {
    await FcmToken(token).put(documentId);
  }
}

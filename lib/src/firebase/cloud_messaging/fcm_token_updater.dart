import 'dart:developer';

import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/fcm_token.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmTokenUpdater {
  final Stream<String> _tokenStream;

  FcmTokenUpdater() : _tokenStream = FirebaseMessaging.instance.onTokenRefresh;

  void putCurrentToken(DocumentWrapper<PublicExpertInfo> expertInfo) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      throw Exception("Unexpected null fcm token");
    }
    log("Current FCM token ${fcmToken}");
    await putToken(expertInfo.documentId, fcmToken);
  }

  void updateTokensOnRefresh(DocumentWrapper<PublicExpertInfo> expertInfo) {
    _tokenStream.listen((fcmToken) async {
      log("FCM token refreshed: ${fcmToken}");
      await putToken(expertInfo.documentId, fcmToken);
    }).onError((err) {
      log("FCM token refresh error: ${err}");
    });
  }

  Future<void> putToken(String documentId, String token) async {
    await FcmToken(token).put(documentId);
  }
}

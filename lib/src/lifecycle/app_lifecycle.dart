import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:expertapp/src/firebase/cloud_messaging/fcm_token_updater.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/firebase/real_time_database/update_presence.dart';
import 'package:flutter/material.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

class AppLifecycle extends ChangeNotifier {
  final _tokenUpdater = FcmTokenUpdater();
  FirebaseAuth.User? _theAuthenticatedUser = null;
  DocumentWrapper<PublicUserInfo>? _thePublicUserInfo = null;
  StreamSubscription? _presenceSubscription = null;

  FirebaseAuth.User? get authenticatedUser => _theAuthenticatedUser;
  DocumentWrapper<PublicUserInfo>? get publicUserInfo => _thePublicUserInfo;

  String? getFirstName() {
    if (publicUserInfo != null) {
      return publicUserInfo!.documentType.firstName;
    }
    if (_theAuthenticatedUser != null &&
        _theAuthenticatedUser!.displayName != null) {
      final splitNames = _theAuthenticatedUser!.displayName!.split(' ');
      if (splitNames.length < 2) return null;
      return splitNames[0];
    }
    return null;
  }

  String? getLastName() {
    if (publicUserInfo != null) {
      return publicUserInfo!.documentType.lastName;
    }
    if (_theAuthenticatedUser != null &&
        _theAuthenticatedUser!.displayName != null) {
      final splitNames = _theAuthenticatedUser!.displayName!.split(' ');
      if (splitNames.length < 2) return null;
      return splitNames[1];
    }
    return null;
  }

  String? getEmail() {
    if (_theAuthenticatedUser != null) {
      return _theAuthenticatedUser!.email;
    }
    return null;
  }

  Future<void> onAuthStatusChange(FirebaseAuth.User? aAuthenticatedUser) async {
    _theAuthenticatedUser = aAuthenticatedUser;
    if (_theAuthenticatedUser != null) {
      onUserLogin(await PublicUserInfo.get(_theAuthenticatedUser!.uid));
    } else {
      onUserLogout();
    }
  }

  void onUserLogin(DocumentWrapper<PublicUserInfo>? currentUser) async {
    _thePublicUserInfo = currentUser;
    _presenceSubscription =
        keepPresenceUpdated(currentUserId: currentUserId()!);
    if (currentUser != null) {
      await _onUserConfirmation();
    }
    notifyListeners();
  }

  Future<void> onUserLogout() async {
    if (_presenceSubscription != null) {
      if (_thePublicUserInfo != null) {
        await markPresenceOffline(currentUserId: currentUserId()!);
      }
      await _presenceSubscription!.cancel();
      _presenceSubscription = null;
    }
    _thePublicUserInfo = null;
    notifyListeners();
  }

  Future<void> _onUserConfirmation() async {
    await _updateFcmTokens();
  }

  Future<void> _updateFcmTokens() async {
    if (Platform.isAndroid) {
      GooglePlayServicesAvailability availability = await GoogleApiAvailability
          .instance
          .checkGooglePlayServicesAvailability(true);

      if (availability == GooglePlayServicesAvailability.success) {
        log("Google Play services are available");
      } else {
        throw Exception("Google Play services unavailable");
      }
    }
    _tokenUpdater.putCurrentToken(_thePublicUserInfo!);
    _tokenUpdater.updateTokensOnRefresh(_thePublicUserInfo!);
  }

  String? currentUserId() {
    return _thePublicUserInfo == null ? null : _thePublicUserInfo!.documentId;
  }
}

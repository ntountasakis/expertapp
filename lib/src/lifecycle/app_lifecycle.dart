import 'dart:developer';
import 'dart:io';

import 'package:expertapp/src/firebase/cloud_messaging/fcm_token_updater.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:flutter/material.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

class AppLifecycle extends ChangeNotifier {
  final _tokenUpdater = FcmTokenUpdater();
  FirebaseAuth.User? _theAuthenticatedUser = null;
  DocumentWrapper<UserMetadata>? _theUserMetadata = null;

  FirebaseAuth.User? get authenticatedUser => _theAuthenticatedUser;
  DocumentWrapper<UserMetadata>? get userMetadata => _theUserMetadata;

  Future<void> onAuthStatusChange(FirebaseAuth.User? aAuthenticatedUser) async {
    _theAuthenticatedUser = aAuthenticatedUser;
    if (_theAuthenticatedUser != null) {
      onUserLogin(await UserMetadata.get(_theAuthenticatedUser!.uid));
    } else {
      notifyListeners();
    }
  }

  void onUserLogin(DocumentWrapper<UserMetadata>? currentUser) async {
    _theUserMetadata = currentUser;
    if (currentUser != null) {
      await _onUserConfirmation();
    }
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
    _tokenUpdater.putCurrentToken(_theUserMetadata!);
    _tokenUpdater.updateTokensOnRefresh(_theUserMetadata!);
  }
}

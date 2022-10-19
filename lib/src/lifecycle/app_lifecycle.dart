import 'dart:developer';
import 'dart:io';

import 'package:expertapp/src/firebase/cloud_messaging/fcm_token_updater.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:expertapp/src/firebase/auth/auth_state_listener.dart' as Auth;

class AppLifecycle {
  final _tokenUpdater = FcmTokenUpdater();
  FirebaseAuth.User? theAuthenticatedUser;
  DocumentWrapper<UserMetadata>? theUserMetadata;

  void onAuthStatusChange(FirebaseAuth.User? aAuthenticatedUser) {
    theAuthenticatedUser = aAuthenticatedUser;
  }

  void onUserLogin(DocumentWrapper<UserMetadata> currentUser) async {
    theUserMetadata = currentUser;
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
    _tokenUpdater.putCurrentToken(currentUser);
    _tokenUpdater.updateTokensOnRefresh(currentUser);
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:expertapp/src/firebase/cloud_messaging/fcm_token_updater.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:google_api_availability/google_api_availability.dart';

class AppLifecycle {
  final _tokenUpdater = FcmTokenUpdater();

  void onUserLogin(DocumentWrapper<UserMetadata> currentUser) async {
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

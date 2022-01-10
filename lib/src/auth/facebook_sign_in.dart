import 'dart:developer';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookSignIn {
  static signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.getInstance().login();
    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken accessToken = result.accessToken!;
      var token = accessToken.token;
      var userId = accessToken.userId;
      log('Facebook signed in with accessToken: $token userId: $userId');
    } else {
      log('Facebook login was unsuccessful');
      var status = result.status;
      var message = result.message;
      log('Status $status');
      log('Message $message');
    }
  }
}

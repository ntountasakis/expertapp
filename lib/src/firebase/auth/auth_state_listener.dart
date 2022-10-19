import 'package:firebase_auth/firebase_auth.dart';

enum AuthStateEnum { NEED_TO_SIGN_IN, SIGNED_IN }

class AuthStateListener {
  static Future<void> listenForAuthChanges(
      Function(AuthStateEnum, User?) loggedInCallback) async {
    await for (final User? userState
        in FirebaseAuth.instance.authStateChanges()) {
      if (userState != null) {
        loggedInCallback(AuthStateEnum.SIGNED_IN, userState);
      } else {
        loggedInCallback(AuthStateEnum.NEED_TO_SIGN_IN, null);
      }
    }
  }
}

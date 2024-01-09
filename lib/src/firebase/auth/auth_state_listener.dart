import 'package:firebase_auth/firebase_auth.dart';

class AuthStateListener {
  static Future<void> listenForAuthChanges(
      Function(User?) loggedInCallback) async {
    await for (final User? userState
        in FirebaseAuth.instance.authStateChanges()) {
      loggedInCallback(userState);
    }
  }
}

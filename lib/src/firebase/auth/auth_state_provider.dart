import 'package:firebase_auth/firebase_auth.dart';

enum AuthStateEnum { START, NEED_TO_SIGN_IN, SIGNED_IN }

class AuthStateProvider {
  User? currentUser;

  Future<void> listenForAuthChanges(
      Function(AuthStateEnum) loggedInCallback) async {
    await for (final User? userState
        in FirebaseAuth.instance.authStateChanges()) {
      if (userState != null) {
        currentUser = userState;
        loggedInCallback(AuthStateEnum.SIGNED_IN);
      } else {
        loggedInCallback(AuthStateEnum.NEED_TO_SIGN_IN);
      }
    }
  }
}

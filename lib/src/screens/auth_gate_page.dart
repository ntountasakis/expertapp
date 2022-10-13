import 'package:firebase_auth/firebase_auth.dart';

// todo: remove
class AuthGatePage {
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

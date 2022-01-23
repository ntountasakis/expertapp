import 'package:expertapp/src/screens/expert_listings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var streamBuilder = StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(providerConfigs: [
            EmailProviderConfiguration(),
          ]);
        }
        return ExpertListings();
      },
    );
    return streamBuilder;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

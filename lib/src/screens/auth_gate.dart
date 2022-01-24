import 'dart:developer';

import 'package:expertapp/src/screens/expert_listings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class AuthGate extends StatelessWidget {
  void handleAuthStateChangeAction(context, AuthState state) {
    if (state is UserCreated) {
      log('new user!!');
    }
  }
  const AuthGate({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var streamBuilder = StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(actions: [
            AuthStateChangeAction(handleAuthStateChangeAction)
          ], providerConfigs: [
            EmailProviderConfiguration(),
            GoogleProviderConfiguration(
              clientId:
                  '111394228371-4slr6ceip09bqefipq2ikbvribtj93qj.apps.googleusercontent.com',
            ),
            FacebookProviderConfiguration(
              clientId: '294313229392786',
            )
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

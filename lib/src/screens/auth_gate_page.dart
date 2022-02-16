import 'dart:developer';

import 'package:expertapp/src/gates/user_creation_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class AuthGatePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(providerConfigs: [
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
        return UserCreationGate(FirebaseAuth.instance.currentUser!);
      },
    );
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
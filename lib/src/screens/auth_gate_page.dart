import 'package:expertapp/src/gates/user_creation_gate.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class AuthGatePage extends StatelessWidget {
  final AppLifecycle _appLifecycle;

  AuthGatePage(this._appLifecycle);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
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
          return UserCreationGate(_appLifecycle, FirebaseAuth.instance.currentUser!);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

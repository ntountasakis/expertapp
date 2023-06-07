import 'package:expertapp/src/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              "Register or Sign In",
            )),
        actions: [
          ElevatedButton(
            onPressed: () async {
              context.goNamed(Routes.HOME_PAGE);
            },
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SignInScreen(),
    );
  }
}

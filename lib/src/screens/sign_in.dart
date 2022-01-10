import 'dart:developer';

import 'package:expertapp/src/auth/facebook_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SignIn extends StatefulWidget {
  @override
  _SignIn createState() => _SignIn();
}

class _SignIn extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Sign In")),
        body: Container(
            child: Column(children: [
          SignInButton(
            Buttons.Facebook,
            onPressed: () async {
              log('Facebook sign in pressed');
              await FacebookSignIn.signInWithFacebook();
            },
          )
        ])));
  }
}

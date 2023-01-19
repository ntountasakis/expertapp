import 'dart:developer';

import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/util/reg_expr_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserSignupPage extends StatefulWidget {
  @override
  State<UserSignupPage> createState() => _UserSignupPageState();
}

class _UserSignupPageState extends State<UserSignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ButtonStyle buttonStyle =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 12));

  late String _firstName;
  late String _lastName;
  late String _email;

  Widget _buildFirstName() {
    return TextFormField(
        decoration: InputDecoration(labelText: 'First Name'),
        validator: (value) {
          if (!RegExprValidator.isValidName(value!)) {
            return 'Please enter a valid name';
          }
          return null;
        },
        onSaved: (value) {
          _firstName = value!;
        });
  }

  Widget _buildLastName() {
    return TextFormField(
        decoration: InputDecoration(labelText: 'Last Name'),
        validator: (value) {
          if (value != null && !RegExprValidator.isValidName(value)) {
            return 'Please enter a valid name';
          }
          return null;
        },
        onSaved: (value) {
          _lastName = value!;
        });
  }

  Widget _buildEmail() {
    return TextFormField(
        decoration: InputDecoration(labelText: 'Email'),
        validator: (value) {
          if (value != null && !RegExprValidator.isValidEmail(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
        onSaved: (value) {
          _email = value!;
        });
  }

  Widget _buildSubmitButton(AppLifecycle lifecycle) {
    return ElevatedButton(
        style: buttonStyle,
        onPressed: () async {
          if (!_formKey.currentState!.validate()) {
            return;
          }
          _formKey.currentState!.save();

          await onUserSignup(_firstName, _lastName, _email,
              lifecycle.authenticatedUser!.photoURL);

          log('New User Signup');

          DocumentWrapper<PublicExpertInfo>? userMetadataWrapper =
              await PublicExpertInfo.get(lifecycle.authenticatedUser!.uid);

          if (userMetadataWrapper == null) {
            throw Exception(
                'Expected ${lifecycle.authenticatedUser!.uid} to exist');
          }

          onUserCreated(lifecycle, userMetadataWrapper);
        },
        child: const Text('Submit'));
  }

  void onUserCreated(AppLifecycle lifecycle,
      DocumentWrapper<PublicExpertInfo> userMetadataWrapper) {
    lifecycle.onUserLogin(userMetadataWrapper);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
          leading: ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.FirebaseAuth.instance.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ),
        body: Consumer<AppLifecycle>(builder: (context, lifecycle, child) {
          return Container(
              child: Form(
                  key: _formKey,
                  child: Column(children: [
                    _buildFirstName(),
                    _buildLastName(),
                    _buildEmail(),
                    _buildSubmitButton(lifecycle)
                  ])));
        }));
  }
}

import 'dart:developer';

import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_information.dart';
import 'package:expertapp/src/screens/auth_gate_page.dart';
import 'package:expertapp/src/screens/expert_listings_page.dart';
import 'package:expertapp/src/util/reg_expr_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserSignupPage extends StatefulWidget {
  final User _authenticatedUser;
  UserSignupPage(this._authenticatedUser);

  @override
  State<UserSignupPage> createState() => _UserSignupPageState();
}

class _UserSignupPageState extends State<UserSignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ButtonStyle buttonStyle =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 12));

  late String _firstName;
  late String _lastName;

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

  Widget _buildSubmitButton() {
    return ElevatedButton(
        style: buttonStyle,
        onPressed: () async {
          if (!_formKey.currentState!.validate()) {
            return;
          }
          _formKey.currentState!.save();

          // final userInfo = UserInformation(
          //     _firstName, _lastName, widget._authenticatedUser.photoURL);
          // await userInfo.set(widget._authenticatedUser.uid);

          await onUserSignup(
              _firstName, _lastName, widget._authenticatedUser.photoURL);
          log('New User Signup');

          DocumentWrapper<UserInformation>? userInfoWrapper =
              await UserInformation.get(widget._authenticatedUser.uid);

          if (userInfoWrapper == null) {
            throw Exception(
                'Expected ${widget._authenticatedUser.uid} to exist');
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExpertListingsPage(userInfoWrapper),
              ));
        },
        child: const Text('Submit'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
          leading: ElevatedButton(
            onPressed: () async {
              await AuthGatePage.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ),
        body: Container(
            child: Form(
                key: _formKey,
                child: Column(children: [
                  _buildFirstName(),
                  _buildLastName(),
                  _buildSubmitButton()
                ]))));
  }
}

import 'dart:developer';

import 'package:expertapp/src/firebase/database/models/user_information.dart';
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

          final userInfo = UserInformation(
              widget._authenticatedUser.uid, _firstName, _lastName);
          await userInfo.put();

          log('User Info Uploaded');
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ExpertListingsPage(userInfo)));
        },
        child: const Text('Submit'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Sign Up")),
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

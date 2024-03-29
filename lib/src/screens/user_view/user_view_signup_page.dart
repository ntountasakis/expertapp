import 'dart:developer';

import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/util/loading_icon.dart';
import 'package:expertapp/src/util/reg_expr_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class UserViewSignupPage extends StatefulWidget {
  String? firstName;
  String? lastName;
  String? email;

  UserViewSignupPage(
      {required this.firstName, required this.lastName, required this.email});

  @override
  State<UserViewSignupPage> createState() => _UserViewSignupPageState();
}

class _UserViewSignupPageState extends State<UserViewSignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ButtonStyle buttonStyle =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 12));
  bool isLoadingUserSignUp = false;

  Widget _buildFirstName() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
          initialValue: widget.firstName,
          decoration: InputDecoration(labelText: 'First Name'),
          validator: (value) {
            if (!RegExprValidator.isValidName(value!)) {
              return 'Please enter a valid name';
            }
            return null;
          },
          onSaved: (value) {
            setState(() {
              widget.firstName = value!;
            });
          }),
    );
  }

  Widget _buildLastName() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
          initialValue: widget.lastName,
          decoration: InputDecoration(labelText: 'Last Name'),
          validator: (value) {
            if (value != null && !RegExprValidator.isValidName(value)) {
              return 'Please enter a valid name';
            }
            return null;
          },
          onSaved: (value) {
            setState(() {
              widget.lastName = value!;
            });
          }),
    );
  }

  Widget _buildEmail() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
          initialValue: widget.email,
          decoration: InputDecoration(labelText: 'Email'),
          validator: (value) {
            if (value != null && !RegExprValidator.isValidEmail(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          onSaved: (value) {
            setState(() {
              widget.email = value!;
            });
          }),
    );
  }

  Future<void> onSubmitPressed(AppLifecycle lifecycle) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() => isLoadingUserSignUp = true);

    await onUserSignup(widget.firstName!, widget.lastName!, widget.email!,
        lifecycle.authenticatedUser!.photoURL);

    log('New User Signup');

    DocumentWrapper<PublicUserInfo>? userMetadataWrapper =
        await PublicUserInfo.get(lifecycle.authenticatedUser!.uid);

    if (userMetadataWrapper == null) {
      throw Exception('Expected ${lifecycle.authenticatedUser!.uid} to exist');
    }

    onUserCreated(lifecycle, userMetadataWrapper);

    setState(() => isLoadingUserSignUp = false);
  }

  Widget _buildSubmitButton(AppLifecycle lifecycle) {
    return ElevatedButton.icon(
        style: buttonStyle,
        onPressed:
            isLoadingUserSignUp ? null : () => onSubmitPressed(lifecycle),
        label: isLoadingUserSignUp ? loadingIcon() : Icon(Icons.check),
        icon: const Text('Submit'));
  }

  void onUserCreated(AppLifecycle lifecycle,
      DocumentWrapper<PublicUserInfo> userMetadataWrapper) {
    lifecycle.onUserLogin(userMetadataWrapper);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              "Sign Up",
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                context.goNamed(Routes.HOME_PAGE);
              },
              child: const Text('Skip'),
            ),
          ],
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

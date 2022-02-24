import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_information.dart';
import 'package:expertapp/src/screens/expert_listings_page.dart';
import 'package:expertapp/src/screens/user_signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserCreationGate extends StatelessWidget {
  final User _authenticatedUser;
  UserCreationGate(this._authenticatedUser);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: UserInformation.get(_authenticatedUser.uid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<UserInformation>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final userInfoWrapper =
                  snapshot.data as DocumentWrapper<UserInformation>;
              return ExpertListingsPage(userInfoWrapper);
            }
            return UserSignupPage(_authenticatedUser);
          }
          return CircularProgressIndicator();
        });
  }
}

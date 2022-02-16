import 'package:expertapp/src/firebase/database/models/user_information.dart';
import 'package:expertapp/src/screens/expert_listings_page.dart';
import 'package:expertapp/src/screens/expert_profile_page.dart';
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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              // return ExpertListingsPage(snapshot.data as UserInformation);
              final userInfo = snapshot.data as UserInformation;
              return ExpertProfilePage(userInfo, userInfo);
            }
            return UserSignupPage(_authenticatedUser);
          }
          return CircularProgressIndicator();
        });
  }
}

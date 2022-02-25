import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/expert_listings_page.dart';
import 'package:expertapp/src/screens/user_signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserMetadata;
import 'package:flutter/material.dart';

class UserCreationGate extends StatelessWidget {
  final User _authenticatedUser;
  UserCreationGate(this._authenticatedUser);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: UserMetadata.get(_authenticatedUser.uid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<UserMetadata>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final userMetadataWrapper =
                  snapshot.data as DocumentWrapper<UserMetadata>;
              return ExpertListingsPage(userMetadataWrapper);
            }
            return UserSignupPage(_authenticatedUser);
          }
          return CircularProgressIndicator();
        });
  }
}

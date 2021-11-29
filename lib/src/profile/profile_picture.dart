import 'package:expertapp/src/firebase/database/models/user_id.dart';
import 'package:expertapp/src/firebase/storage/profile_pic_loader.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final UserId _userId;

  ProfilePicture(this._userId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ProfilePicLoader().getProfilePicURL(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ClipOval(child: Image.network(snapshot.data as String));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

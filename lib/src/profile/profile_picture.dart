import 'package:expertapp/src/firebase/storage/profile_pic_loader.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String _uid;

  ProfilePicture(this._uid);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ProfilePicLoader().getProfilePicURL(_uid),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return ClipOval(child: Image.network(snapshot.data as String));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

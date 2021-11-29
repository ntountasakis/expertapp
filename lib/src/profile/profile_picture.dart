import 'package:expertapp/src/firebase/storage/profile_pic_loader.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final _imagePath;

  ProfilePicture(this._imagePath);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ProfilePicLoader().getProfilePicURL(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ClipOval(child: Image.network(snapshot.data as String));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

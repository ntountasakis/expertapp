import 'package:expertapp/src/firebase/storage/storage_paths.dart';
import 'package:expertapp/src/firebase/storage/storage_util.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String _profilePicturePath;

  ProfilePicture(String? profilePictureUrl)
      : _profilePicturePath = profilePictureUrl != null
            ? StoragePaths.PROFILE_PICS + profilePictureUrl
            : StoragePaths.DEFAULT_PROFILE_PIC;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: StorageUtil.getDownloadUrl(_profilePicturePath),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          String pictureUrl = snapshot.data as String;
          return ClipOval(child: Image.network(pictureUrl));
        }
        return CircularProgressIndicator();
      },
    );
  }
}

import 'package:expertapp/src/firebase/storage/storage_paths.dart';
import 'package:expertapp/src/firebase/storage/storage_util.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String? _profilePictureUrl;

  ProfilePicture(this._profilePictureUrl);

  Widget _imageWidget(String url) {
    return ClipOval(child: Image.network(url));
  }

  @override
  Widget build(BuildContext context) {
    if (_profilePictureUrl != null) {
      return _imageWidget(_profilePictureUrl!);
    }
    return FutureBuilder(
      future: StorageUtil.getDownloadUrl(StoragePaths.DEFAULT_PROFILE_PIC),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          String pictureUrl = snapshot.data as String;
          return _imageWidget(pictureUrl);
        }
        return CircularProgressIndicator();
      },
    );
  }
}

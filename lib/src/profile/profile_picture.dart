import 'dart:developer';
import 'dart:typed_data';

import 'package:expertapp/src/firebase/storage/storage_paths.dart';
import 'package:expertapp/src/firebase/storage/storage_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProfilePicture extends StatelessWidget {
  final String? profilePicUrl;
  final Function(Uint8List selectedProfilePicBytes)? onProfilePicSelection;

  ProfilePicture(this.profilePicUrl, [this.onProfilePicSelection]);

  Widget _imageWidget(String url) {
    return ClipOval(child: Image.network(url));
  }

  Widget _asyncPicLoader() {
    if (profilePicUrl != null) {
      return _imageWidget(profilePicUrl!);
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

  Widget _profilePicUploadButton() {
    return IconButton(
        icon: Icon(
          Icons.camera_alt_rounded,
          size: 30,
          color: Colors.grey,
        ),
        tooltip: 'Upload a profile picture',
        onPressed: () async {
          final ImagePicker picker = ImagePicker();
          try {
            final XFile? image =
                await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              Uint8List imageBytes = await image.readAsBytes();
              onProfilePicSelection!(imageBytes);
            } else {
              log('User cancelled profile pic image upload');
            }
          } on PlatformException catch (e) {
            log('Exception picking image:  $e');
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: FittedBox(
            child: _asyncPicLoader(),
          ),
        ),
        if (onProfilePicSelection != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: _profilePicUploadButton(),
          ),
      ],
    );
  }
}

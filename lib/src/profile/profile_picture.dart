import 'dart:developer';

import 'package:expertapp/src/environment/environment_config.dart';
import 'package:expertapp/src/firebase/storage/storage_paths.dart';
import 'package:expertapp/src/firebase/storage/storage_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ProfilePicture extends StatelessWidget {
  final String? profilePicUrl;
  final bool fromSignUpFlow;
  final VoidCallback? onProfilePicUpload;
  final void Function(
      {required Uint8List selectedProfilePicBytes,
      required bool fromSignUpFlow,
      required VoidCallback? onProfilePictureChanged})? onProfilePicSelection;

  ProfilePicture(this.profilePicUrl,
      [this.fromSignUpFlow = false,
      this.onProfilePicUpload,
      this.onProfilePicSelection]);

  Widget _imageWidget(String url) {
    if (!EnvironmentConfig.getConfig().isProd()) {
      url = StorageUtil.getLocalhostUrlForStorageUrl(url);
    }
    return CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: NetworkImage(url),
    );
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

  Widget _profilePicUploadButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.camera_alt_rounded,
        size: 30,
        color: Colors.grey,
      ),
      tooltip: 'Upload a profile picture',
      onPressed: () async {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Center(child: Text("Select photo source")),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actions: [
                  TextButton(
                    child: Text("Camera"),
                    onPressed: () async {
                      uploadNewImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text("Photo Gallery"),
                    onPressed: () async {
                      uploadNewImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      },
    );
  }

  Future<void> uploadNewImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        Uint8List imageBytes = await image.readAsBytes();
        final imageHandle = img.decodeImage(imageBytes);
        if (imageHandle == null) {
          log('Failed to decode image');
        } else {
          Uint8List jpegBytes = img.encodeJpg(imageHandle, quality: 50);
          onProfilePicSelection!(
              selectedProfilePicBytes: jpegBytes,
              fromSignUpFlow: fromSignUpFlow,
              onProfilePictureChanged: onProfilePicUpload);
        }
      } else {
        log('User cancelled profile pic image upload');
      }
    } on Exception catch (e) {
      log('Exception picking image:  $e');
    }
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
            child: _profilePicUploadButton(context),
          ),
      ],
    );
  }
}

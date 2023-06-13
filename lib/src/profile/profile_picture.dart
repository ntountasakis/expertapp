import 'dart:developer';

import 'package:expertapp/src/environment/environment_config.dart';
import 'package:expertapp/src/firebase/storage/storage_paths.dart';
import 'package:expertapp/src/firebase/storage/storage_util.dart';
import 'package:expertapp/src/util/permission_prompts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicture extends StatefulWidget {
  final String? profilePicUrl;
  final bool fromSignUpFlow;
  final VoidCallback? onProfilePicUpload;
  final Future<void> Function(
      {required Uint8List selectedProfilePicBytes,
      required bool fromSignUpFlow,
      required VoidCallback? onProfilePictureChanged})? onProfilePicSelection;

  ProfilePicture(this.profilePicUrl,
      [this.fromSignUpFlow = false,
      this.onProfilePicUpload,
      this.onProfilePicSelection]);

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  bool isUploadingPicture = false;

  Widget _imageWidget(String url) {
    if (isUploadingPicture) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      );
    } else {
      if (!EnvironmentConfig.getConfig().isProd()) {
        url = StorageUtil.getLocalhostUrlForStorageUrl(url);
      }
      return CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(url),
      );
    }
  }

  Widget _asyncPicLoader() {
    if (widget.profilePicUrl != null) {
      return _imageWidget(widget.profilePicUrl!);
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

  Future<void> uploadPicture() async {
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
  }

  Widget _profilePicUploadButton(BuildContext context) {
    if (isUploadingPicture) {
      return SizedBox();
    }
    return IconButton(
      icon: Icon(
        Icons.camera_alt_rounded,
        size: 30,
        color: Colors.grey,
      ),
      tooltip: 'Upload a profile picture',
      onPressed: isUploadingPicture ? null : uploadPicture,
    );
  }

  Future<void> uploadNewImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final shouldProceed = await promptCamera(context);
      if (!shouldProceed) return;
    }
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() => isUploadingPicture = true);
        Uint8List imageBytes = await image.readAsBytes();
        Uint8List jpegBytes = await FlutterImageCompress.compressWithList(
            imageBytes,
            minHeight: 400,
            minWidth: 400,
            quality: 50,
            format: CompressFormat.jpeg);
        await widget.onProfilePicSelection!(
            selectedProfilePicBytes: jpegBytes,
            fromSignUpFlow: widget.fromSignUpFlow,
            onProfilePictureChanged: widget.onProfilePicUpload);
        setState(() => isUploadingPicture = false);
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
        if (widget.onProfilePicSelection != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: _profilePicUploadButton(context),
          ),
      ],
    );
  }
}

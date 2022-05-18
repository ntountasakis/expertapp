import 'dart:typed_data';
import 'dart:developer';

import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final DocumentWrapper<UserMetadata> userMetadata;

  const UserProfilePage(this.userMetadata);

  void onProfilePicSelection(Uint8List profilePicBytes) async {
    // TODO, this crashes iOS 13 simulator via Rosetta.
    try {
      final picUrl = await onProfilePicUpload(pictureBytes: profilePicBytes);
    } catch (e) {
      log("picture upload failed ${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: Text(
              userMetadata.documentType.firstName,
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(
            width: 200,
            height: 200,
            child: ProfilePicture(
                userMetadata.documentType.profilePicUrl, onProfilePicSelection),
          ),
        ],
      ),
    );
  }
}

import 'dart:typed_data';
import 'dart:developer';

import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  final DocumentWrapper<PublicExpertInfo> userMetadata;

  const UserProfilePage(this.userMetadata);

  @override
  State<UserProfilePage> createState() =>
      _UserProfilePageState(userMetadata.documentType.profilePicUrl);
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _profilePicUrl;

  _UserProfilePageState(this._profilePicUrl);

  void onProfilePicSelection(Uint8List profilePicBytes) async {
    // TODO, this crashes iOS 13 simulator via Rosetta.
    try {
      final publicUrl = await onProfilePicUpload(pictureBytes: profilePicBytes);
      await widget.userMetadata.documentType
          .updateProfilePic(widget.userMetadata.documentId, publicUrl);

      setState(() {
        _profilePicUrl = publicUrl;
      });
    } catch (e) {
      log("picture upload failed ${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: Text(
              widget.userMetadata.documentType.firstName,
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(
            width: 200,
            height: 200,
            child: ProfilePicture(_profilePicUrl, onProfilePicSelection),
          ),
        ],
      ),
    );
  }
}

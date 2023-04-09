import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void onProfilePicSelection(
    Uint8List profilePicBytes, VoidCallback? onProfilePictureChanged) async {
  // TODO, this crashes iOS 13 simulator via Rosetta.
  await onProfilePicUpload(pictureBytes: profilePicBytes);
  if (onProfilePictureChanged != null) {
    onProfilePictureChanged();
  }
}

Widget buildProfilePictureExpertView(
    DocumentWrapper<PublicExpertInfo> publicExpertInfo,
    VoidCallback? onProfilePictureUploaded) {
  return SizedBox(
    width: 150,
    height: 150,
    child: ProfilePicture(publicExpertInfo.documentType.profilePicUrl,
        onProfilePictureUploaded, onProfilePicSelection),
  );
}

Widget buildProfilePictureUserView(
    DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
  return SizedBox(
    width: 150,
    height: 150,
    child: ProfilePicture(publicExpertInfo.documentType.profilePicUrl),
  );
}
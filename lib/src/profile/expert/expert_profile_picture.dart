import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_profile_pic_with_presence.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void onProfilePicSelection(
    {required Uint8List selectedProfilePicBytes,
    required bool fromSignUpFlow,
    required VoidCallback? onProfilePictureChanged}) async {
  await onProfilePicUpload(
      pictureBytes: selectedProfilePicBytes, fromSignUpFlow: fromSignUpFlow);
  if (onProfilePictureChanged != null) {
    onProfilePictureChanged();
  }
}

Widget buildProfilePictureExpertView({
  required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  required bool fromSignUpFlow,
  required VoidCallback? onProfilePictureUploaded,
}) {
  return SizedBox(
    width: 150,
    height: 150,
    child: ProfilePicture(publicExpertInfo.documentType.profilePicUrl,
        fromSignUpFlow, onProfilePictureUploaded, onProfilePicSelection),
  );
}

Widget buildProfilePictureUserView(
    DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
  return SizedBox(
    width: 150,
    height: 150,
    child: buildExpertProfilePicWithPresence(
      profilePicUrl: publicExpertInfo.documentType.profilePicUrl,
      isOnline: publicExpertInfo.documentType.isOnline,
      isAvailable: publicExpertInfo.documentType.isAvailable(),
      bottomOffset: 10,
      rightOffset: 10,
      circleSize: 30,
    ),
  );
}

import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_profile_heading_description.dart';
import 'package:expertapp/src/profile/expert/expert_profile_picture.dart';
import 'package:expertapp/src/util/expert_category_util.dart';
import 'package:flutter/material.dart';

Widget buildExpertProfileHeaderHelper({
  required BuildContext context,
  required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  required TextEditingController? textController,
  required ExpertCategorySelector? categorySelector,
  required VoidCallback? onProfilePictureChanged,
  required bool isExpertView,
  required bool fromSignUpFlow,
}) {
  return Row(
    children: [
      SizedBox(
        width: 5,
      ),
      isExpertView
          ? buildProfilePictureExpertView(
              publicExpertInfo: publicExpertInfo,
              fromSignUpFlow: fromSignUpFlow,
              onProfilePictureUploaded: onProfilePictureChanged)
          : buildProfilePictureUserView(publicExpertInfo),
      SizedBox(
        width: 10,
      ),
      isExpertView
          ? buildExpertProfileHeadingDescriptionExpertView(
              context: context,
              publicExpertInfo: publicExpertInfo,
              textController: textController!,
              categorySelector: categorySelector!)
          : buildExpertProfileHeadingDescriptionUserView(
              context, publicExpertInfo),
    ],
    crossAxisAlignment: CrossAxisAlignment.start,
  );
}

Widget buildExpertProfileHeaderExpertView({
  required BuildContext context,
  required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  required TextEditingController textController,
  required ExpertCategorySelector categorySelector,
  required bool fromSignUpFlow,
  required VoidCallback? onProfilePictureChanged,
}) {
  return buildExpertProfileHeaderHelper(
      context: context,
      publicExpertInfo: publicExpertInfo,
      textController: textController,
      categorySelector: categorySelector,
      onProfilePictureChanged: onProfilePictureChanged,
      fromSignUpFlow: fromSignUpFlow,
      isExpertView: true);
}

Widget buildExpertProfileHeaderUserView(
    BuildContext context, DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
  return buildExpertProfileHeaderHelper(
      context: context,
      publicExpertInfo: publicExpertInfo,
      textController: null,
      categorySelector: null,
      onProfilePictureChanged: null,
      fromSignUpFlow: false,
      isExpertView: false);
}

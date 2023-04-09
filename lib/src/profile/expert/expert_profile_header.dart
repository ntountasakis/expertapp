import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_profile_heading_description.dart';
import 'package:expertapp/src/profile/expert/expert_profile_picture.dart';
import 'package:expertapp/src/util/expert_category_util.dart';
import 'package:flutter/material.dart';

Widget buildExpertProfileHeaderHelper(
    BuildContext context,
    DocumentWrapper<PublicExpertInfo> publicExpertInfo,
    TextEditingController? controller,
    ExpertCategorySelector? categorySelector,
    VoidCallback? onProfilePictureChanged,
    bool isExpertView,
    bool fromSignUpFlow) {
  return Row(
    children: [
      SizedBox(
        width: 5,
      ),
      isExpertView
          ? buildProfilePictureExpertView(
              publicExpertInfo, fromSignUpFlow, onProfilePictureChanged)
          : buildProfilePictureUserView(publicExpertInfo),
      SizedBox(
        width: 10,
      ),
      isExpertView
          ? buildExpertProfileHeadingDescriptionExpertView(
              context, publicExpertInfo, controller!, categorySelector!)
          : buildExpertProfileHeadingDescriptionUserView(
              context, publicExpertInfo),
    ],
    crossAxisAlignment: CrossAxisAlignment.start,
  );
}

Widget buildExpertProfileHeaderExpertView(
  BuildContext context,
  DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  TextEditingController controller,
  ExpertCategorySelector categorySelector,
  bool fromSignUpFlow,
  VoidCallback? onProfilePictureChanged,
) {
  return buildExpertProfileHeaderHelper(context, publicExpertInfo, controller,
      categorySelector, onProfilePictureChanged, fromSignUpFlow, true);
}

Widget buildExpertProfileHeaderUserView(
    BuildContext context, DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
  return buildExpertProfileHeaderHelper(
      context, publicExpertInfo, null, null, null, false, false);
}

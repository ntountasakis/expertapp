import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_profile_edit_button.dart';
import 'package:expertapp/src/util/expert_category_util.dart';
import 'package:flutter/material.dart';

Widget buildExpertProfileHeadingDescriptionHelper({
  required BuildContext context,
  required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  required TextEditingController? textController,
  required ExpertCategorySelector? categorySelector,
  required bool isExpertView,
}) {
  final name = Text(
    publicExpertInfo.documentType.shortName(),
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
  final majorCategory = Expanded(
    child: Text(
      "${publicExpertInfo.documentType.majorCategory()}",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
  final minorCategory = Text(
    "Specializes in ${publicExpertInfo.documentType.minorCategory()}",
    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
  final editCategoryButton = isExpertView
      ? buildExpertProfileEditCategoryButton(
          context: context,
          publicExpertInfo: publicExpertInfo,
          textController: textController!,
          categorySelector: categorySelector!)
      : SizedBox();
  return Expanded(
    child: Column(
      children: [
        name,
        SizedBox(height: 10),
        Row(children: [
          majorCategory,
          editCategoryButton,
        ]),
        minorCategory,
      ],
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
    ),
  );
}

Widget buildExpertProfileHeadingDescriptionExpertView({
  required BuildContext context,
  required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  required TextEditingController textController,
  required ExpertCategorySelector categorySelector,
}) {
  return buildExpertProfileHeadingDescriptionHelper(
      context: context,
      publicExpertInfo: publicExpertInfo,
      textController: textController,
      categorySelector: categorySelector,
      isExpertView: true);
}

Widget buildExpertProfileHeadingDescriptionUserView(
  BuildContext context,
  DocumentWrapper<PublicExpertInfo> publicExpertInfo,
) {
  return buildExpertProfileHeadingDescriptionHelper(
      context: context,
      publicExpertInfo: publicExpertInfo,
      textController: null,
      categorySelector: null,
      isExpertView: false);
}

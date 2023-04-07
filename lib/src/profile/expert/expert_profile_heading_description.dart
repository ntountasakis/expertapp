import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_profile_edit_button.dart';
import 'package:expertapp/src/util/expert_category_util.dart';
import 'package:flutter/material.dart';

Widget buildExpertProfileHeadingDescriptionHelper(
    BuildContext context,
    DocumentWrapper<PublicExpertInfo> publicExpertInfo,
    TextEditingController? textController,
    ExpertCategorySelector? categorySelector,
    bool isExpertView) {
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
          context, publicExpertInfo, textController!, categorySelector!)
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

Widget buildExpertProfileHeadingDescriptionExpertView(
  BuildContext context,
  DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  TextEditingController textController,
  ExpertCategorySelector categorySelector,
) {
  return buildExpertProfileHeadingDescriptionHelper(
      context, publicExpertInfo, textController, categorySelector, true);
}

Widget buildExpertProfileHeadingDescriptionUserView(
  BuildContext context,
  DocumentWrapper<PublicExpertInfo> publicExpertInfo,
) {
  return buildExpertProfileHeadingDescriptionHelper(
      context, publicExpertInfo, null, null, false);
}

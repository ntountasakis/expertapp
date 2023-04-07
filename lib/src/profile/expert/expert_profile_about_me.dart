import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_profile_description.dart';
import 'package:expertapp/src/profile/expert/expert_profile_edit_button.dart';
import 'package:expertapp/src/profile/expert/expert_rating.dart';
import 'package:flutter/material.dart';

Widget buildExpertProfileAboutMeTitle(
    DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
  return Text(
    "About Me",
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
  );
}

Widget buildExpertProfileAboutMeHelper(
    BuildContext context,
    DocumentWrapper<PublicExpertInfo> publicExpertInfo,
    ScrollController controller,
    TextEditingController? textController,
    bool isExpertView) {
  return Container(
    margin: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                buildExpertProfileAboutMeTitle(publicExpertInfo),
                Spacer(),
                isExpertView
                    ? buildExpertProfileEditAboutMeButton(
                        context, publicExpertInfo, textController!)
                    : SizedBox(),
              ],
            ),
            buildExpertProfileRating(publicExpertInfo),
            SizedBox(height: 10),
            buildExpertProfileDescription(controller, publicExpertInfo),
          ],
        ),
      ),
    ),
  );
}

Widget buildExpertProfileAboutMeUserView(
    BuildContext context,
    DocumentWrapper<PublicExpertInfo> publicExpertInfo,
    ScrollController controller) {
  return buildExpertProfileAboutMeHelper(
      context, publicExpertInfo, controller, null, false);
}

Widget buildExpertProfileAboutMeExpertView(
    BuildContext context,
    DocumentWrapper<PublicExpertInfo> publicExpertInfo,
    ScrollController controller,
    TextEditingController textController) {
  return buildExpertProfileAboutMeHelper(
      context, publicExpertInfo, controller, textController, true);
}

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
    {required BuildContext context,
    required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
    required ScrollController scrollController,
    required TextEditingController? textController,
    required Function(String)? onAboutMeChanged,
    required bool isExpertView,
    required bool fromSignUpFlow}) {
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
                        context: context,
                        publicExpertInfo: publicExpertInfo,
                        textController: textController!,
                        fromSignUpFlow: fromSignUpFlow,
                        onAboutMeChanged: onAboutMeChanged)
                    : SizedBox(),
              ],
            ),
            buildExpertProfileRating(publicExpertInfo),
            SizedBox(height: 10),
            buildExpertProfileDescription(
                scrollController: scrollController,
                publicExpertInfo: publicExpertInfo),
          ],
        ),
      ),
    ),
  );
}

Widget buildExpertProfileAboutMeUserView(
    {required BuildContext context,
    required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
    required ScrollController controller}) {
  return buildExpertProfileAboutMeHelper(
      context: context,
      publicExpertInfo: publicExpertInfo,
      scrollController: controller,
      textController: null,
      onAboutMeChanged: null,
      fromSignUpFlow: false,
      isExpertView: false);
}

Widget buildExpertProfileAboutMeExpertView(
    {required BuildContext context,
    required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
    required ScrollController scrollController,
    required TextEditingController textController,
    required bool fromSignUpFlow,
    required Function(String)? onAboutMeChanged}) {
  return buildExpertProfileAboutMeHelper(
      context: context,
      publicExpertInfo: publicExpertInfo,
      scrollController: scrollController,
      textController: textController,
      onAboutMeChanged: onAboutMeChanged,
      fromSignUpFlow: fromSignUpFlow,
      isExpertView: true);
}

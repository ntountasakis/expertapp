import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/util/expert_category_util.dart';
import 'package:flutter/material.dart';

Future openExpertProfileEditDescriptionDialog({
  required BuildContext context,
  required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  required TextEditingController textController,
  required bool fromSignUpFlow,
  required Function(String)? onAboutMeChanged,
}) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceBetween,
            title: Text("Edit Description"),
            content: TextFormField(
              autofocus: true,
              maxLines: null,
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter a description",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final newDescription =
                      textController.text.trim().replaceAll("\n", " ");
                  final result = await updateProfileDescription(
                      newDescription, fromSignUpFlow);
                  if (!result.success) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title:
                                Text("Please revise your profile description"),
                            content: Text(result.message),
                          );
                        });
                  }
                  if (onAboutMeChanged != null) {
                    onAboutMeChanged(result.success ? "" : result.message);
                  }
                },
                child: Text("Save"),
              ),
            ],
          ));
}

Future openExpertProfileEditCategoryDialog({
  required BuildContext context,
  required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  required ExpertCategorySelector categorySelector,
}) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceBetween,
      title: Text("Edit your category of expertise"),
      content: categorySelector,
    ),
  );
}

Widget buildExpertProfileEditCategoryButton({
  required BuildContext context,
  required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  required TextEditingController textController,
  required ExpertCategorySelector categorySelector,
}) {
  return IconButton(
    icon: const Icon(
      Icons.edit,
      size: 30,
      color: Colors.grey,
    ),
    onPressed: () {
      openExpertProfileEditCategoryDialog(
          context: context,
          publicExpertInfo: publicExpertInfo,
          categorySelector: categorySelector);
    },
  );
}

Widget buildExpertProfileEditAboutMeButton({
  required BuildContext context,
  required DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  required TextEditingController textController,
  required bool fromSignUpFlow,
  required Function(String)? onAboutMeChanged,
}) {
  return IconButton(
    icon: const Icon(
      Icons.edit,
      size: 30,
      color: Colors.grey,
    ),
    onPressed: () {
      openExpertProfileEditDescriptionDialog(
          context: context,
          publicExpertInfo: publicExpertInfo,
          textController: textController,
          fromSignUpFlow: fromSignUpFlow,
          onAboutMeChanged: onAboutMeChanged);
    },
  );
}

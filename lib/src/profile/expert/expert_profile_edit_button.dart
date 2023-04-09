import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/util/expert_category_util.dart';
import 'package:flutter/material.dart';

Future openExpertProfileEditDescriptionDialog(
  BuildContext context,
  DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  TextEditingController textController,
  Function(String)? onAboutMeChanged,
) {
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
                  final result = await updateProfileDescription(newDescription);
                  if (onAboutMeChanged != null) {
                    onAboutMeChanged(result.success ? "" : result.message);
                  }
                },
                child: Text("Save"),
              ),
            ],
          ));
}

Future openExpertProfileEditCategoryDialog(
    BuildContext context,
    DocumentWrapper<PublicExpertInfo> publicExpertInfo,
    ExpertCategorySelector categorySelector) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceBetween,
      title: Text("Edit your category of expertise"),
      content: categorySelector,
    ),
  );
}

Widget buildExpertProfileEditCategoryButton(
  BuildContext context,
  DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  TextEditingController textController,
  ExpertCategorySelector categorySelector,
) {
  return IconButton(
    icon: const Icon(
      Icons.edit,
      size: 30,
      color: Colors.grey,
    ),
    onPressed: () {
      openExpertProfileEditCategoryDialog(
          context, publicExpertInfo, categorySelector);
    },
  );
}

Widget buildExpertProfileEditAboutMeButton(
  BuildContext context,
  DocumentWrapper<PublicExpertInfo> publicExpertInfo,
  TextEditingController textController,
  Function(String)? onAboutMeChanged,
) {
  return IconButton(
    icon: const Icon(
      Icons.edit,
      size: 30,
      color: Colors.grey,
    ),
    onPressed: () {
      openExpertProfileEditDescriptionDialog(
          context, publicExpertInfo, textController, onAboutMeChanged);
    },
  );
}

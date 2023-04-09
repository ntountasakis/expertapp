import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_profile_about_me.dart';
import 'package:expertapp/src/profile/expert/expert_profile_header.dart';
import 'package:expertapp/src/profile/expert/expert_profile_scaffold.dart';
import 'package:expertapp/src/util/expert_category_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ExpertViewExpertProfilePage extends StatefulWidget {
  final String expertUid;

  ExpertViewExpertProfilePage({required this.expertUid});

  @override
  State<ExpertViewExpertProfilePage> createState() =>
      _ExpertViewExpertProfilePageState();
}

class _ExpertViewExpertProfilePageState
    extends State<ExpertViewExpertProfilePage> {
  final descriptionScrollController = ScrollController();
  late ExpertCategorySelector categorySelector;
  late TextEditingController textController;
  String textControllerText = "Loading...";

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    textController.text = textControllerText;
    categorySelector = new ExpertCategorySelector(widget.expertUid, () {});
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void updateProfileDescriptionIfChanged(
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) async {
    if (publicExpertInfo.documentType.description != textControllerText) {
      textControllerText = publicExpertInfo.documentType.description;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        textController.text = textControllerText;
      });
    }
  }

  void onAboutMeChanged(String aboutMeUpdatedTextError) {
    if (aboutMeUpdatedTextError != "") {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Please revise your profile description"),
              content: Text(aboutMeUpdatedTextError),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpertProfileScaffold(
      expertUid: widget.expertUid,
      appBarBuilder: ExpertProfileScaffold.buildDefaultAppbar,
      profileHeaderBuilder:
          (DocumentWrapper<PublicExpertInfo>? publicExpertInfo) {
        return buildExpertProfileHeaderExpertView(context, publicExpertInfo!,
            textController, categorySelector, false, null);
      },
      aboutMeBuilder: (DocumentWrapper<PublicExpertInfo>? publicExpertInfo) {
        return buildExpertProfileAboutMeExpertView(
            context,
            publicExpertInfo!,
            descriptionScrollController,
            textController,
            false,
            onAboutMeChanged);
      },
      onUpdate: (DocumentWrapper<PublicExpertInfo>? publicExpertInfo) {
        updateProfileDescriptionIfChanged(publicExpertInfo!);
      },
    );
  }
}

// return ExpertPostSignupAppbar(
//   uid: widget._expertUid,
//   titleText: "Click arrow to finish",
//   nextRoute: Routes.HOME_PAGE,
//   addAdditionalParams: false,
//   allowBackButton: true,
// );

import 'package:expertapp/src/appbars/expert_view/expert_post_signup_appbar.dart';
import 'package:expertapp/src/appbars/user_view/expert_profile_appbar.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/expert/expert_profile_about_me.dart';
import 'package:expertapp/src/profile/expert/expert_profile_header.dart';
import 'package:expertapp/src/profile/expert/expert_profile_scaffold.dart';
import 'package:expertapp/src/util/expert_category_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ExpertViewExpertProfileSignUpPage extends StatefulWidget {
  final String expertUid;

  ExpertViewExpertProfileSignUpPage({required this.expertUid});

  @override
  State<ExpertViewExpertProfileSignUpPage> createState() =>
      _ExpertViewExpertProfileSignUpPageState();
}

class _ExpertViewExpertProfileSignUpPageState
    extends State<ExpertViewExpertProfileSignUpPage> {
  final descriptionScrollController = ScrollController();
  late ExpertCategorySelector categorySelector;
  late TextEditingController textController;
  String textControllerText = "Loading...";
  bool categorySelectionFinished = false;
  bool profilePictureChanged = false;
  String aboutMeUpdatedText = "";

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    textController.text = textControllerText;
    categorySelector =
        new ExpertCategorySelector(widget.expertUid, onExpertCategoryChanged);
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

  void onExpertCategoryChanged() {
    setState(() {
      categorySelectionFinished = true;
    });
  }

  void onProfilePictureChanged() {
    setState(() {
      profilePictureChanged = true;
    });
  }

  void onAboutMeChanged(String aboutMeUpdatedText) {
    setState(() {
      this.aboutMeUpdatedText = aboutMeUpdatedText;
    });
  }

  bool aboutMeTextSufficientLength() {
    return aboutMeUpdatedText.length > 30;
  }

  void onDisallowedProceedPressed() {
    String text = "";
    if (!profilePictureChanged) {
      text = "Please upload a profile picture";
    } else if (!categorySelectionFinished) {
      text = "Please select your category of expertise";
    } else if (!aboutMeTextSufficientLength()) {
      if (aboutMeUpdatedText == "") {
        text = "Please fill out your about me section";
      } else
        text = "Your about me section is too short";
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Your profile is not complete"),
            content: Text(text),
          );
        });
  }

  PreferredSizeWidget buildAppbar(
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    if (snapshot.hasData) {
      final allowProceed = aboutMeTextSufficientLength() &&
          profilePictureChanged &&
          categorySelectionFinished;
      return ExpertPostSignupAppbar(
        uid: widget.expertUid,
        titleText:
            allowProceed ? "Click arrow to finish" : "Fill out profile details",
        nextRoute: Routes.HOME_PAGE,
        addAdditionalParams: false,
        allowBackButton: true,
        allowProceed: allowProceed,
        onDisallowedProceedPressed: onDisallowedProceedPressed,
      );
    }
    return AppBar(
      title: Text("Loading..."),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpertProfileScaffold(
      appBarBuilder: buildAppbar,
      expertUid: widget.expertUid,
      profileHeaderBuilder:
          (DocumentWrapper<PublicExpertInfo>? publicExpertInfo) {
        return buildExpertProfileHeaderExpertView(context, publicExpertInfo!,
            textController, categorySelector, onProfilePictureChanged);
      },
      aboutMeBuilder: (DocumentWrapper<PublicExpertInfo>? publicExpertInfo) {
        return buildExpertProfileAboutMeExpertView(context, publicExpertInfo!,
            descriptionScrollController, textController, onAboutMeChanged);
      },
      onUpdate: (DocumentWrapper<PublicExpertInfo>? publicExpertInfo) {
        updateProfileDescriptionIfChanged(publicExpertInfo!);
      },
    );
  }
}

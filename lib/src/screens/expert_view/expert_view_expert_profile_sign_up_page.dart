import 'package:expertapp/src/appbars/expert_view/expert_post_signup_appbar.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/expert/expert_profile_about_me.dart';
import 'package:expertapp/src/profile/expert/expert_profile_header.dart';
import 'package:expertapp/src/profile/expert/expert_profile_scaffold.dart';
import 'package:expertapp/src/util/expert_category_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

class ExpertViewExpertProfileSignUpPage extends StatefulWidget {
  final String expertUid;
  static bool FROM_SIGN_UP_FLOW = true;

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
  String? aboutMeUpdatedTextError = null;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    textController.text = textControllerText;
    categorySelector = new ExpertCategorySelector(
        uid: widget.expertUid,
        onComplete: onExpertCategoryChanged,
        fromSignUpFlow: ExpertViewExpertProfileSignUpPage.FROM_SIGN_UP_FLOW);
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

  void onAboutMeChanged(String aboutMeUpdatedTextError) {
    setState(() {
      this.aboutMeUpdatedTextError = aboutMeUpdatedTextError;
    });
  }

  void onDisallowedProceedPressed() {
    String text = "";
    if (!profilePictureChanged) {
      text = "Please upload a profile picture";
    } else if (!categorySelectionFinished) {
      text = "Please select your category of expertise";
    } else if (aboutMeUpdatedTextError != null) {
      text = aboutMeUpdatedTextError!;
    } else {
      text = "Please fill in your about me";
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

  Future<void> onProceedPressed(BuildContext context) async {
    final result = await completeExpertSignUp();
    if (result.success) {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Thanks for signing up!"),
              content: Text("You may now start accepting calls"),
            );
          });
          // todo: this context is invalid, throws error sometimes
      context.pushReplacementNamed(Routes.HOME_PAGE);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("An error occurred"),
              content: Text(result.message),
            );
          });
    }
  }

  PreferredSizeWidget buildAppbar(
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    if (snapshot.hasData) {
      final allowProceed = aboutMeUpdatedTextError == "" &&
          profilePictureChanged &&
          categorySelectionFinished;
      return ExpertPostSignupAppbar(
        uid: widget.expertUid,
        titleText:
            allowProceed ? "Click arrow to finish" : "Fill out profile details",
        allowBackButton: true,
        allowProceed: allowProceed,
        onDisallowedProceedPressed: onDisallowedProceedPressed,
        onAllowProceedPressed: onProceedPressed,
      );
    }
    return AppBar(
      title: Text("Loading..."),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpertProfileScaffold(
      fromSignUpFlow: ExpertViewExpertProfileSignUpPage.FROM_SIGN_UP_FLOW,
      appBarBuilder: buildAppbar,
      expertUid: widget.expertUid,
      profileHeaderBuilder:
          (DocumentWrapper<PublicExpertInfo>? publicExpertInfo) {
        return buildExpertProfileHeaderExpertView(
            context: context,
            publicExpertInfo: publicExpertInfo!,
            textController: textController,
            categorySelector: categorySelector,
            fromSignUpFlow: ExpertViewExpertProfileSignUpPage.FROM_SIGN_UP_FLOW,
            onProfilePictureChanged: onProfilePictureChanged);
      },
      aboutMeBuilder: (DocumentWrapper<PublicExpertInfo>? publicExpertInfo) {
        return buildExpertProfileAboutMeExpertView(
            context: context,
            publicExpertInfo: publicExpertInfo!,
            scrollController: descriptionScrollController,
            textController: textController,
            fromSignUpFlow: ExpertViewExpertProfileSignUpPage.FROM_SIGN_UP_FLOW,
            onAboutMeChanged: onAboutMeChanged);
      },
      onUpdate: (DocumentWrapper<PublicExpertInfo>? publicExpertInfo) {
        updateProfileDescriptionIfChanged(publicExpertInfo!);
      },
    );
  }
}

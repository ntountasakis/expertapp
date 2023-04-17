import 'package:expertapp/src/appbars/expert_view/expert_post_signup_appbar.dart';
import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_signup_progress.dart';
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
  String? aboutMeUpdatedTextError = null;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    textController.text = textControllerText;
    categorySelector = new ExpertCategorySelector(
        uid: widget.expertUid,
        onComplete: () {},
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

  void onAboutMeChanged(String aboutMeUpdatedTextError) {
    setState(() {
      this.aboutMeUpdatedTextError = aboutMeUpdatedTextError;
    });
  }

  void onDisallowedProceedPressed(
      BuildContext context, ExpertSignupProgress progress) {
    String text = "";
    if (!progress.updatedProfilePic) {
      text = "Please upload a profile picture";
    } else if (!progress.updatedExpertCategory) {
      text = "Please select your category of expertise";
    } else if (!progress.updatedProfileDescription) {
      if (aboutMeUpdatedTextError != null) {
        text = aboutMeUpdatedTextError!;
      } else {
        text = "Please fill in your about me";
      }
    } else {
      throw Exception(
          "Disallow proceed pressed in expert profile sign up page but progress in unexcepted state: " +
              progress.toString());
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
      BuildContext context, DocumentWrapper<ExpertSignupProgress>? progress) {
    if (progress == null) {
      return ExpertProfileScaffold.buildDefaultAppBar();
    }
    bool allowProceed = progress.documentType.updatedExpertCategory &&
        progress.documentType.updatedProfileDescription &&
        progress.documentType.updatedProfilePic;
    final builder = ExpertPostSignupAppbar(
      uid: widget.expertUid,
      titleText:
          allowProceed ? "Click arrow to finish" : "Fill Out Profile Details",
      progress: progress.documentType,
      allowBackButton: true,
      allowProceed: allowProceed,
      onDisallowedProceedPressed: onDisallowedProceedPressed,
      onAllowProceedPressed: onProceedPressed,
    );
    return builder.buildAppBar(context);
  }

  @override
  Widget build(BuildContext context) {
    return ExpertProfileScaffold(
      currentUserId: widget.expertUid,
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
            onProfilePictureChanged: () {});
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

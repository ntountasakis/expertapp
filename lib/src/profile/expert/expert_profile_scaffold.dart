import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_signup_progress.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_call_action_buttons.dart';
import 'package:expertapp/src/profile/expert/expert_profile_reviews.dart';
import 'package:flutter/material.dart';

class ExpertProfileScaffold extends StatelessWidget {
  final String? currentUserId;
  final String expertUid;
  final bool fromSignUpFlow;
  final PreferredSizeWidget Function(BuildContext context,
      DocumentWrapper<ExpertSignupProgress>? progress)? appBarBuilder;
  final Function(DocumentWrapper<PublicExpertInfo>?) profileHeaderBuilder;
  final Function(DocumentWrapper<PublicExpertInfo>?) aboutMeBuilder;
  final Function(DocumentWrapper<PublicExpertInfo>?)? onUpdate;
  static String DEFAULT_APP_BAR_TITLE = "View Expert Profile";

  const ExpertProfileScaffold(
      {Key? key,
      required this.currentUserId,
      required this.expertUid,
      required this.fromSignUpFlow,
      required this.appBarBuilder,
      required this.profileHeaderBuilder,
      required this.aboutMeBuilder,
      required this.onUpdate})
      : super(key: key);

  static PreferredSizeWidget buildDefaultAppBar() {
    return AppBar(
      title: Text(ExpertProfileScaffold.DEFAULT_APP_BAR_TITLE),
    );
  }

  Widget buildBody(
      {required BuildContext context,
      required DocumentWrapper<PublicExpertInfo>? publicExpertInfo,
      required String? currentUserId}) {
    if (onUpdate != null) {
      onUpdate!(publicExpertInfo);
    }
    return Column(
      children: [
        SizedBox(height: 10),
        profileHeaderBuilder(publicExpertInfo),
        aboutMeBuilder(publicExpertInfo),
        !fromSignUpFlow ? buildExpertProfileReviewHeading() : SizedBox(),
        !fromSignUpFlow
            ? buildExpertProfileReviewList(publicExpertInfo!)
            : SizedBox(),
        !fromSignUpFlow
            ? buildExpertProfileCallActionButton(
                context: context,
                publicExpertInfo: publicExpertInfo!,
                currentUserUid: currentUserId)
            : SizedBox(),
        SizedBox(height: 30),
      ],
    );
  }

  Widget buildHelper(
      {required BuildContext context,
      required AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?>
          expertInfoSnapshot,
      required AsyncSnapshot<DocumentWrapper<ExpertSignupProgress>?>?
          progressSnapshot,
      required String? currentUserId}) {
    if (!expertInfoSnapshot.hasData) {
      return Scaffold(
        appBar: buildDefaultAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: appBarBuilder != null
          ? appBarBuilder!(context, progressSnapshot?.data)
          : buildDefaultAppBar(),
      body: buildBody(
          context: context,
          publicExpertInfo: expertInfoSnapshot.data,
          currentUserId: currentUserId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentWrapper<PublicExpertInfo>?>(
        stream: PublicExpertInfo.getStreamForUser(
            uid: expertUid, fromSignUpFlow: fromSignUpFlow),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?>
                publicExpertInfoSnapshot) {
          if (!fromSignUpFlow) {
            return buildHelper(
                context: context,
                expertInfoSnapshot: publicExpertInfoSnapshot,
                progressSnapshot: null,
                currentUserId: currentUserId);
          } else {
            return StreamBuilder<DocumentWrapper<ExpertSignupProgress>?>(
                stream: ExpertSignupProgress.getStreamForUser(uid: expertUid),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentWrapper<ExpertSignupProgress>?>
                        expertSignupProgressSnapshot) {
                  return buildHelper(
                      context: context,
                      expertInfoSnapshot: publicExpertInfoSnapshot,
                      progressSnapshot: expertSignupProgressSnapshot,
                      currentUserId: currentUserId);
                });
          }
        });
  }
}

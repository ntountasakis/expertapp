import 'package:expertapp/src/appbars/user_view/expert_profile_appbar.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_call_action_buttons.dart';
import 'package:expertapp/src/profile/expert/expert_profile_reviews.dart';
import 'package:flutter/material.dart';

class ExpertProfileScaffold extends StatelessWidget {
  final String expertUid;
  final bool fromSignUpFlow;
  final PreferredSizeWidget Function(
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?>) appBarBuilder;
  final Function(DocumentWrapper<PublicExpertInfo>?) profileHeaderBuilder;
  final Function(DocumentWrapper<PublicExpertInfo>?) aboutMeBuilder;
  final Function(DocumentWrapper<PublicExpertInfo>?)? onUpdate;

  const ExpertProfileScaffold(
      {Key? key,
      required this.expertUid,
      required this.fromSignUpFlow,
      required this.appBarBuilder,
      required this.profileHeaderBuilder,
      required this.aboutMeBuilder,
      required this.onUpdate})
      : super(key: key);

  Widget buildBody(BuildContext context,
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    if (snapshot.hasData) {
      final publicExpertInfo = snapshot.data;
      if (onUpdate != null) {
        onUpdate!(publicExpertInfo);
      }
      return Column(
        children: [
          SizedBox(height: 10),
          profileHeaderBuilder(publicExpertInfo),
          aboutMeBuilder(publicExpertInfo),
          buildExpertProfileReviewHeading(),
          buildExpertProfileReviewList(publicExpertInfo!),
          buildExpertProfileCallActionButton(
              context, publicExpertInfo, expertUid),
          SizedBox(height: 30),
        ],
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  static PreferredSizeWidget buildDefaultAppbar(
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    if (snapshot.hasData) {
      return ExpertProfileAppbar(expertUid: snapshot.data!.documentId);
    }
    return AppBar(
      title: Text("Loading..."),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentWrapper<PublicExpertInfo>?>(
        stream: PublicExpertInfo.getStreamForUser(
            uid: expertUid, fromSignUpFlow: fromSignUpFlow),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
          return Scaffold(
            appBar: appBarBuilder(snapshot),
            body: buildBody(context, snapshot),
          );
        });
  }
}

import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_profile_about_me.dart';
import 'package:expertapp/src/profile/expert/expert_profile_header.dart';
import 'package:expertapp/src/profile/expert/expert_profile_scaffold.dart';
import 'package:flutter/material.dart';

class UserViewExpertProfilePage extends StatelessWidget {
  final String? currentUid;
  final String expertUid;
  final _descriptionScrollController = ScrollController();

  UserViewExpertProfilePage(
      {Key? key, required this.currentUid, required this.expertUid});

  @override
  Widget build(BuildContext context) {
    return ExpertProfileScaffold(
      currentUserId: currentUid,
      fromSignUpFlow: false,
      appBarBuilder: null,
      expertUid: expertUid,
      profileHeaderBuilder:
          (DocumentWrapper<PublicExpertInfo>? publicExpertInfo) {
        return buildExpertProfileHeaderUserView(context, publicExpertInfo!);
      },
      aboutMeBuilder: (DocumentWrapper<PublicExpertInfo>? publicExpertInfo) {
        return buildExpertProfileAboutMeUserView(
            context: context,
            publicExpertInfo: publicExpertInfo!,
            controller: _descriptionScrollController);
      },
      onUpdate: null,
    );
  }
}

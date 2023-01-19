import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

class UserPreviewAppbar extends StatelessWidget with PreferredSizeWidget {
  final DocumentWrapper<PublicExpertInfo> userMetadata;
  final String namePrefix;

  UserPreviewAppbar(this.userMetadata, this.namePrefix);

  String buildTitle() {
    String title = userMetadata.documentType.firstName;
    if (namePrefix != "") {
      title = namePrefix + " " + title;
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(buildTitle()),
          ),
          SizedBox(
            width: 15,
          ),
          SizedBox(
            height: 45,
            width: 45,
            child: ProfilePicture(userMetadata.documentType.profilePicUrl),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

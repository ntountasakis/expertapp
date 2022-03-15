import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

class UserPreviewAppbar extends StatelessWidget with PreferredSizeWidget {
  final DocumentWrapper<UserMetadata> userMetadata;

  UserPreviewAppbar(this.userMetadata);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          SizedBox(
            height: 45,
            width: 45,
            child: ProfilePicture(userMetadata.documentType.profilePicUrl),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Text(userMetadata.documentType.firstName +
                " " +
                userMetadata.documentType.lastName),
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

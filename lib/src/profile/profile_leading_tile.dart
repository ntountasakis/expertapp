import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

Widget buildLeadingProfileTile(
    BuildContext context, String shortName, String profilePicUrl) {
  final TextStyle nameStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  return SizedBox(
    width: 100,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IntrinsicWidth(
          child: Text(
            shortName,
            style: nameStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 5),
        Expanded(
          child: ProfilePicture(profilePicUrl),
        ),
      ],
    ),
  );
}

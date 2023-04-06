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
        shortName != ""
            ? IntrinsicWidth(
                child: Text(
                shortName,
                style: nameStyle,
                overflow: TextOverflow.ellipsis,
              ))
            : SizedBox(),
        shortName != "" ? SizedBox(height: 5) : SizedBox(),
        Expanded(
          child: ProfilePicture(profilePicUrl),
        ),
        SizedBox(height: 5),
      ],
    ),
  );
}

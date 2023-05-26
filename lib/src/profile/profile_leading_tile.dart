import 'package:expertapp/src/profile/expert/expert_profile_pic_with_presence.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

Widget buildLeadingProfileTile(
    {required BuildContext context,
    required String shortName,
    required String profilePicUrl,
    required bool showOnlineStatus,
    required bool isOnline,
    required bool isAvailable}) {
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
        buildProfilePicTileElement(
          profilePicUrl: profilePicUrl,
          showOnlineStatus: showOnlineStatus,
          isOnline: isOnline,
          isAvailable: isAvailable,
        ),
        SizedBox(height: 5),
      ],
    ),
  );
}

Widget buildProfilePicTileElement(
    {required String profilePicUrl,
    required bool showOnlineStatus,
    required bool isOnline,
    required bool isAvailable}) {
  if (!showOnlineStatus) {
    return Expanded(
      child: ProfilePicture(profilePicUrl),
    );
  }
  return Expanded(
      child: buildExpertProfilePicWithPresence(
          profilePicUrl: profilePicUrl,
          isOnline: isOnline,
          isAvailable: isAvailable,
          bottomOffset: 0,
          rightOffset: 20,
          circleSize: 15));
}

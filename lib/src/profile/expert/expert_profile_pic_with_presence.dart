import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

Widget buildExpertProfilePicWithPresence(
    {required String profilePicUrl,
    required bool isOnline,
    required double bottomOffset,
    required double rightOffset,
    required double circleSize}) {
  return Stack(children: [
    ProfilePicture(profilePicUrl),
    Positioned(
      bottom: bottomOffset,
      right: rightOffset,
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          color: isOnline ? Colors.green : Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    ),
  ]);
}

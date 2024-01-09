import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

Widget buildExpertProfilePicWithPresence(
    {required String profilePicUrl,
    required bool isOnline,
    required bool isAvailable,
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
          color: !isAvailable
              ? Colors.red
              : (isOnline ? Colors.green : Colors.yellow[600]),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    ),
  ]);
}

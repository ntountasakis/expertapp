import 'package:expertapp/src/profile/expert/expert_profile_page.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

class ExpertListingPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ExpertProfilePage()));
      },
      child: Container(
        width: 48,
        height: 48,
        child: ProfilePicture('assets/images/man-profile.jpg'),
      ),
    ));
  }
}

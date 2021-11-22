import 'package:expertapp/src/profile/expert/expert_profile_page.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

import 'database/models/user_id.dart';

class ExpertListingPreview extends StatelessWidget {
  final UserId _userId;

  const ExpertListingPreview(this._userId);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpertProfilePage(_userId)));
            },
            child: IntrinsicWidth(
                child: ListTile(
                    leading: ProfilePicture('assets/images/man-profile.jpg'),
                    title: Expanded(child: Text(_userId.name))))));
  }
}

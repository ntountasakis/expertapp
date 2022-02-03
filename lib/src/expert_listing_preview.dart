import 'package:expertapp/src/firebase/database/models/user_information.dart';
import 'package:expertapp/src/screens/expert_profile_page.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

class ExpertListingPreview extends StatelessWidget {
  final UserInformation _currentUser;
  final UserInformation _expertUserInfo;

  const ExpertListingPreview(this._currentUser, this._expertUserInfo);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExpertProfilePage(_currentUser, _expertUserInfo)));
            },
            child: IntrinsicWidth(
                child: ListTile(
                    leading: ProfilePicture(_expertUserInfo.profilePicUrl),
                    title: Text(_expertUserInfo.firstName)))));
  }
}

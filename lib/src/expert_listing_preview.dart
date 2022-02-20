import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_information.dart';
import 'package:expertapp/src/screens/expert_profile_page.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

class ExpertListingPreview extends StatelessWidget {
  final DocumentWrapper<UserInformation> _currentUser;
  final DocumentWrapper<UserInformation> _expertUserInfo;

  const ExpertListingPreview(this._currentUser, this._expertUserInfo);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ExpertProfilePage(_currentUser, _expertUserInfo),
                ));
          },
          child: SizedBox(
            width: 50,
            child: ProfilePicture(_expertUserInfo.documentType.profilePicUrl),
          ),
        ),
        title: Text(_expertUserInfo.documentType.firstName),
      ),
    );
  }
}

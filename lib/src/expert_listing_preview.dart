import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_information.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/expert_profile_page.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

class ExpertListingPreview extends StatelessWidget {
  final DocumentWrapper<UserInformation> _currentUser;
  final DocumentWrapper<UserMetadata> _expertUserMetadata;

  const ExpertListingPreview(this._currentUser, this._expertUserMetadata);

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
                      ExpertProfilePage(_currentUser, _expertUserMetadata),
                ));
          },
          child: SizedBox(
            width: 50,
            child: ProfilePicture(_expertUserMetadata.documentType.profilePicUrl),
          ),
        ),
        title: Text(_expertUserMetadata.documentType.firstName),
      ),
    );
  }
}

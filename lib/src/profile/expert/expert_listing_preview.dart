import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/screens/navigation/expert_profile_arguments.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';

class ExpertListingPreview extends StatelessWidget {
  final DocumentWrapper<UserMetadata> _expertUserMetadata;

  const ExpertListingPreview(this._expertUserMetadata);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, Routes.EXPERT_PROFILE_PAGE,
                arguments: ExpertProfileArguments(this._expertUserMetadata));
          },
          child: SizedBox(
            width: 50,
            child:
                ProfilePicture(_expertUserMetadata.documentType.profilePicUrl),
          ),
        ),
        title: Text(_expertUserMetadata.documentType.firstName),
      ),
    );
  }
}

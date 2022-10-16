import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:flutter/material.dart';

class ExpertListingPreview extends StatelessWidget {
  final DocumentWrapper<UserMetadata> _expertUserMetadata;
  final Function(DocumentWrapper<UserMetadata>) _onExpertSelected;

  const ExpertListingPreview(this._expertUserMetadata, this._onExpertSelected);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            _onExpertSelected(_expertUserMetadata);
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

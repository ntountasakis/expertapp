import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertListingPreview extends StatelessWidget {
  final DocumentWrapper<PublicExpertInfo> _publicExpertInfo;

  const ExpertListingPreview(this._publicExpertInfo);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            context.pushNamed(Routes.EXPERT_PROFILE_PAGE,
                params: {Routes.EXPERT_ID_PARAM: _publicExpertInfo.documentId});
          },
          child: SizedBox(
            width: 50,
            child: ProfilePicture(_publicExpertInfo.documentType.profilePicUrl),
          ),
        ),
        title: Text(_publicExpertInfo.documentType.firstName),
      ),
    );
  }
}

import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/profile/star_rating.dart';
import 'package:expertapp/src/profile/expert/expert_reviews.dart';
import 'package:expertapp/src/profile/text_rating.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/routes.dart';

class ExpertProfilePage extends StatelessWidget {
  final String _expertUid;

  ExpertProfilePage(this._expertUid);

  Widget buildCallPreviewButton(
      BuildContext context, DocumentWrapper<UserMetadata> expertUserMetadata) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      backgroundColor: Colors.green[500],
      elevation: 4.0,
      shadowColor: Colors.green[900],
    );
    return Row(
      children: [
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
              style: style,
              onPressed: () async {
                context.pushNamed(Routes.EXPERT_CALL_PREVIEW_PAGE, params: {
                  Routes.EXPERT_ID_PARAM: expertUserMetadata.documentId
                });
              },
              child: Text('Call ${expertUserMetadata.documentType.firstName}')),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget buildRating(DocumentWrapper<UserMetadata> expertUserMetadata) {
    return Row(
      children: [
        Flexible(
            flex: 20,
            child: StarRating(
                expertUserMetadata!.documentType.getAverageReviewRating(),
                25.0)),
        Spacer(flex: 1),
        Flexible(
            flex: 20,
            child: TextRating(
                expertUserMetadata!.documentType.getAverageReviewRating(),
                18.0))
      ],
    );
  }

  Widget buildDescription() {
    return Text(
      """Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor 
    incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut 
    aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. 
    Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum""",
      style: TextStyle(fontSize: 14),
    );
  }

  Widget buildAboutMeName(DocumentWrapper<UserMetadata> expertUserMetadata) {
    return Text(
      expertUserMetadata.documentType.fullName(),
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }

  Widget buildAboutMe(DocumentWrapper<UserMetadata> expertUserMetadata) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildAboutMeName(expertUserMetadata),
              buildRating(expertUserMetadata),
              SizedBox(height: 10),
              buildDescription(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReviewHeading() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            "Customer Reviews",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Spacer()
      ],
    );
  }

  Widget buildReviewList(DocumentWrapper<UserMetadata> expertUserMetadata) {
    return Expanded(
      child: ExpertReviews(expertUserMetadata),
    );
  }

  Widget buildProfilePicture(DocumentWrapper<UserMetadata> expertUserMetadata) {
    return SizedBox(
      width: 200,
      height: 200,
      child: ProfilePicture(expertUserMetadata.documentType.profilePicUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Profile"),
      ),
      body: FutureBuilder<DocumentWrapper<UserMetadata>?>(
          future: UserMetadata.get(_expertUid),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentWrapper<UserMetadata>?> snapshot) {
            if (snapshot.hasData) {
              final expertUserMetadata = snapshot.data;
              return Column(
                children: [
                  SizedBox(height: 10),
                  buildProfilePicture(expertUserMetadata!),
                  SizedBox(height: 10),
                  buildCallPreviewButton(context, expertUserMetadata),
                  buildAboutMe(expertUserMetadata),
                  buildReviewHeading(),
                  buildReviewList(expertUserMetadata),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}

import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/profile/star_rating.dart';
import 'package:expertapp/src/profile/expert/expert_reviews.dart';
import 'package:expertapp/src/profile/text_rating.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpertProfilePage extends StatefulWidget {
  final String _expertUid;

  ExpertProfilePage(this._expertUid);

  @override
  State<ExpertProfilePage> createState() => _ExpertProfilePageState();
}

class _ExpertProfilePageState extends State<ExpertProfilePage> {
  final _descriptionScrollController = ScrollController();

  Widget buildCallPreviewButton(BuildContext context,
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
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
                  Routes.EXPERT_ID_PARAM: publicExpertInfo.documentId
                });
              },
              child: Text('Call ${publicExpertInfo.documentType.firstName}')),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget buildRating(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return Row(
      children: [
        Flexible(
            flex: 20,
            child: StarRating(
                publicExpertInfo.documentType.getAverageReviewRating(), 25.0)),
        Spacer(flex: 1),
        Flexible(
            flex: 20,
            child: TextRating(
                publicExpertInfo.documentType.getAverageReviewRating(), 18.0))
      ],
    );
  }

  Widget buildDescription(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return SizedBox(
      height: 100,
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 2.0,
        controller: _descriptionScrollController,
        child: SingleChildScrollView(
            controller: _descriptionScrollController,
            child: Text(
              publicExpertInfo.documentType.description,
              style: TextStyle(fontSize: 12),
            )),
      ),
    );
  }

  Widget buildAboutMeName(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return Text(
      publicExpertInfo.documentType.fullName(),
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }

  Widget buildAboutMe(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
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
              buildAboutMeName(publicExpertInfo),
              buildRating(publicExpertInfo),
              SizedBox(height: 10),
              buildDescription(publicExpertInfo),
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

  Widget buildReviewList(DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return Expanded(
      child: ExpertReviews(publicExpertInfo),
    );
  }

  Widget buildProfilePicture(
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return SizedBox(
      width: 200,
      height: 200,
      child: ProfilePicture(publicExpertInfo.documentType.profilePicUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expert Profile"),
      ),
      body: FutureBuilder<DocumentWrapper<PublicExpertInfo>?>(
          future: PublicExpertInfo.get(widget._expertUid),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
            if (snapshot.hasData) {
              final publicExpertInfo = snapshot.data;
              return Column(
                children: [
                  SizedBox(height: 10),
                  buildProfilePicture(publicExpertInfo!),
                  SizedBox(height: 10),
                  buildCallPreviewButton(context, publicExpertInfo),
                  buildAboutMe(publicExpertInfo),
                  buildReviewHeading(),
                  buildReviewList(publicExpertInfo),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}

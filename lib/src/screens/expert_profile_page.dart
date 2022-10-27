import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/profile/star_rating.dart';
import 'package:expertapp/src/profile/expert/expert_reviews.dart';
import 'package:expertapp/src/profile/text_rating.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'navigation/routes.dart';

class ExpertProfilePage extends StatelessWidget {
  final String _expertUid;

  ExpertProfilePage(this._expertUid);

  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  Widget buildCallPreviewButton(
      BuildContext context, DocumentWrapper<UserMetadata> expertUserMetadata) {
    return ElevatedButton(
      style: style,
      onPressed: () async {
        context.pushNamed(Routes.EXPERT_CALL_PREVIEW_PAGE,
            params: {Routes.EXPERT_ID_PARAM: expertUserMetadata.documentId});
      },
      child: Text('Call ${expertUserMetadata.documentType.firstName}'),
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
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      expertUserMetadata!.documentType.firstName,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: ProfilePicture(
                        expertUserMetadata.documentType.profilePicUrl),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          flex: 20,
                          child: StarRating(
                              expertUserMetadata!.documentType
                                  .getAverageReviewRating(),
                              25.0)),
                      Spacer(flex: 1),
                      Flexible(
                          flex: 20,
                          child: TextRating(
                              expertUserMetadata!.documentType
                                  .getAverageReviewRating(),
                              18.0))
                    ],
                  ),
                  buildCallPreviewButton(context, expertUserMetadata),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text("Customer Reviews"),
                      ),
                      Spacer()
                    ],
                  ),
                  Expanded(
                    child: ExpertReviews(expertUserMetadata!),
                  )
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }

  // TODO revive in call transaction
  // Widget buildReviewSubmitButton(BuildContext context) {
  //   return ElevatedButton(
  //     style: style,
  //     onPressed: () {
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => ExpertReviewSubmitPage(
  //                   widget._currentUserUid, widget._expertUserMetadata)));
  //     },
  //     child: const Text('Write a Review'),
  //   );
  // }

}

import 'dart:developer';

import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/profile/star_rating.dart';
import 'package:expertapp/src/profile/expert/expert_reviews.dart';
import 'package:expertapp/src/profile/text_rating.dart';
import 'package:expertapp/src/screens/chat_page.dart';
import 'package:expertapp/src/screens/transaction/client/call_transaction_client_preview.dart';
import 'package:expertapp/src/screens/video_call_page.dart';
import 'package:flutter/material.dart';

import 'expert_review_submit_page.dart';

class ExpertProfilePage extends StatefulWidget {
  final String _currentUserUid;
  final DocumentWrapper<UserMetadata> _expertUserMetadata;
  ExpertProfilePage(this._currentUserUid, this._expertUserMetadata);

  @override
  _ExpertProfilePageState createState() => _ExpertProfilePageState();
}

class _ExpertProfilePageState extends State<ExpertProfilePage> {
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Expert Profile"),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              child: Text(
                widget._expertUserMetadata.documentType.firstName,
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: ProfilePicture(
                  widget._expertUserMetadata.documentType.profilePicUrl),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                    flex: 20,
                    child: StarRating(
                        widget._expertUserMetadata.documentType
                            .getAverageReviewRating(),
                        25.0)),
                Spacer(flex: 1),
                Flexible(
                    flex: 20,
                    child: TextRating(
                        widget._expertUserMetadata.documentType
                            .getAverageReviewRating(),
                        18.0))
              ],
            ),
            buildCallPreviewButton(context),
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
              child: ExpertReviews(widget._expertUserMetadata),
            )
          ],
        ));
  }

  Widget buildCallPreviewButton(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: () async {
        DocumentWrapper<ExpertRate>? expertRate =
            await ExpertRate.get(widget._expertUserMetadata.documentId);
        if (expertRate == null) {
          log('Cant find expert rate for ${widget._expertUserMetadata.documentId}');
          return;
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CallTransactionClientPreview(
                    widget._currentUserUid,
                    widget._expertUserMetadata,
                    expertRate.documentType)));
      },
      child: Text('Call ${widget._expertUserMetadata.documentType.firstName}'),
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

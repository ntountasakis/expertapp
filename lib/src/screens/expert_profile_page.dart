import 'dart:developer';

import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/profile/star_rating.dart';
import 'package:expertapp/src/profile/expert/expert_reviews.dart';
import 'package:expertapp/src/profile/text_rating.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_preview.dart';
import 'package:expertapp/src/screens/transaction/client/call_transaction_page_enum.dart';
import 'package:flutter/material.dart';

class ExpertProfilePage extends StatelessWidget {
  final String _currentUserUid;
  final DocumentWrapper<UserMetadata> _expertUserMetadata;
  final Function(CallTransactionPageEnum) onPageTransitionRequest;
  
  ExpertProfilePage(this._currentUserUid, this._expertUserMetadata,
  this.onPageTransitionRequest);

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
                _expertUserMetadata.documentType.firstName,
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: ProfilePicture(
                  _expertUserMetadata.documentType.profilePicUrl),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                    flex: 20,
                    child: StarRating(
                        _expertUserMetadata.documentType
                            .getAverageReviewRating(),
                        25.0)),
                Spacer(flex: 1),
                Flexible(
                    flex: 20,
                    child: TextRating(
                        _expertUserMetadata.documentType
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
              child: ExpertReviews(_expertUserMetadata),
            )
          ],
        ));
  }

  Widget buildCallPreviewButton(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: () async {
        DocumentWrapper<ExpertRate>? expertRate =
            await ExpertRate.get(_expertUserMetadata.documentId);
        if (expertRate == null) {
          log('Cant find expert rate for ${_expertUserMetadata.documentId}');
          return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CallClientPreview(
              _currentUserUid, _expertUserMetadata, expertRate.documentType,
              onPageTransitionRequest);
        }));
      },
      child: Text('Call ${_expertUserMetadata.documentType.firstName}'),
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

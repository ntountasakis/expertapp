import 'dart:typed_data';

import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_information.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/firebase/storage/storage_paths.dart';
import 'package:expertapp/src/firebase/storage/storage_util.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/profile/star_rating.dart';
import 'package:expertapp/src/profile/expert/expert_reviews.dart';
import 'package:expertapp/src/profile/text_rating.dart';
import 'package:expertapp/src/screens/auth_gate_page.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'expert_review_submit_page.dart';

class ExpertProfilePage extends StatefulWidget {
  final DocumentWrapper<UserInformation> _currentUser;
  final DocumentWrapper<UserMetadata> _expertUserMetadata;
  ExpertProfilePage(this._currentUser, this._expertUserMetadata);

  @override
  _ExpertProfilePageState createState() => _ExpertProfilePageState();
}

class _ExpertProfilePageState extends State<ExpertProfilePage> {
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  void onProfilePicSelection(Uint8List profilePicBytes) async {
    // TODO, this crashes iOS 13 simulator via Rosetta.
    await onProfilePicUpload(pictureBytes: profilePicBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: ElevatedButton(
              style: style,
              onPressed: () async {
                await AuthGatePage.signOut();
              },
              child: const Text('Sign Out'),
            ),
            title: const Text("Expert Profile")),
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
                  widget._expertUserMetadata.documentType.profilePicUrl,
                  onProfilePicSelection),
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
            Row(children: [
              ElevatedButton(
                style: style,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ExpertReviewSubmitPage(
                              widget._currentUser,
                              widget._expertUserMetadata)));
                },
                child: const Text('Write a Review'),
              ),
            ]),
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
}

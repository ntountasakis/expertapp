import 'dart:typed_data';

import 'package:expertapp/src/firebase/database/models/user_information.dart';
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
  final UserInformation _currentUser;
  final UserInformation _expertUserInfo;
  late String? _profilePicUrl;
  ExpertProfilePage(this._currentUser, this._expertUserInfo) {
    this._profilePicUrl = this._expertUserInfo.profilePicUrl;
  }

  @override
  _ExpertProfilePageState createState() => _ExpertProfilePageState();
}

class _ExpertProfilePageState extends State<ExpertProfilePage> {
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  void onProfilePicSelection(Uint8List profilePicBytes) async {
    final String imageName = Uuid().v4();
    final String imageUploadPath = StoragePaths.PROFILE_PICS + imageName;
    await StorageUtil.uploadFile(profilePicBytes, imageUploadPath);

    // todo implement deletion
    String uploadedImageUrl = await StorageUtil.getDownloadUrl(imageUploadPath);
    widget._expertUserInfo.updateProfilePicUrl(uploadedImageUrl);
    await widget._expertUserInfo.put();
    setState(() {
      widget._profilePicUrl = uploadedImageUrl;
    });
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
                widget._expertUserInfo.firstName,
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: ProfilePicture(
                  widget._expertUserInfo.profilePicUrl, onProfilePicSelection),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(flex: 20, child: StarRating(3.5, 25.0)),
                Spacer(flex: 1),
                Flexible(flex: 20, child: TextRating(3.5, 18.0))
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
                              widget._expertUserInfo.uid,
                              widget._currentUser.uid)));
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
              child: ExpertReviews(widget._expertUserInfo),
            )
          ],
        ));
  }
}

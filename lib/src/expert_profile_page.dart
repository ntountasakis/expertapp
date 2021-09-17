import 'package:expertapp/src/profile_picture.dart';
import 'package:expertapp/src/star_rating.dart';
import 'package:expertapp/src/expert_reviews.dart';
import 'package:expertapp/src/text_rating.dart';
import 'package:flutter/material.dart';

class ExpertProfilePage extends StatefulWidget {
  @override
  _ExpertProfilePageState createState() => _ExpertProfilePageState();
}

class _ExpertProfilePageState extends State<ExpertProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Expert Profile")),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "John Doe",
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: ProfilePicture('assets/images/man-profile.jpg'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(flex: 20, child: StarRating(3.5, 25.0)),
                Spacer(flex: 1),
                Flexible(flex: 20, child: TextRating(3.5, 18.0))
              ],
            ),
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
              child: ExpertReviews(),
            )
          ],
        ));
  }
}

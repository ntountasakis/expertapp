import 'package:flutter/material.dart';
import 'package:expertapp/src/star_rating.dart';
import 'dart:developer';

class ExpertReview extends StatelessWidget {
  final String _reviewerName;
  final String _review;
  final double _rating;

  ExpertReview(this._reviewerName, this._review, this._rating);

  factory ExpertReview.fromRTDB(reviewerName, Map<String, dynamic> data) {
    var review = data['review'];
    var rating = data['rating'].toDouble();
    return ExpertReview(reviewerName, review, rating);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        padding: EdgeInsets.all(0.0),
        margin: EdgeInsets.all(0.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(children: [
              Row(children: [
                Wrap(
                    spacing: 8.0,
                    alignment: WrapAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Text(_reviewerName, style: TextStyle(fontSize: 16)),
                      StarRating(_rating, 16.0)
                    ])
              ]),
              Expanded(
                  child: Scrollbar(
                      child: SingleChildScrollView(child: Text(_review))))
            ]),
          ),
        ));
  }
}

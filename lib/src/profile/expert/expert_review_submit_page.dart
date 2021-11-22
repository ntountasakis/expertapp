import 'package:expertapp/src/database/expert_review_writer.dart';
import 'package:expertapp/src/database/models/user_id.dart';
import 'package:expertapp/src/profile/expert/expert_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ExpertReviewSubmitPage extends StatefulWidget {
  final UserId _expertUserId;
  ExpertReviewSubmitPage(this._expertUserId);

  @override
  State<ExpertReviewSubmitPage> createState() => _ExpertReviewSubmitPageState();
}

class _ExpertReviewSubmitPageState extends State<ExpertReviewSubmitPage> {
  final formKey = GlobalKey<FormState>();
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  final focusNode = FocusNode();

  String _review = '';
  double _rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Leave a Review")),
        body: Form(
            key: formKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                buildTextReview(),
                const SizedBox(height: 16),
                buildNumericalRating(),
                const SizedBox(height: 16),
                buildSubmit(),
              ],
            )));
  }

  Widget buildTextReview() => TextFormField(
        focusNode: focusNode,
        minLines: 1,
        maxLines: 5,
        decoration: InputDecoration(
            labelText: "Text Review", border: OutlineInputBorder()),
        onChanged: (value) => setState(() => _review = value),
      );

  Widget buildNumericalRating() => RatingBar.builder(
        initialRating: 3,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (starRating) {
          setState(() {
            _rating = starRating;
          });
        },
      );

  Widget buildSubmit() => ElevatedButton(
      style: style,
      onPressed: () {
        var myNewReview = ExpertReview("Nick T", _review, _rating);
        var myReviewWriter = ExpertReviewWriter();
        myReviewWriter.uploadReview(widget._expertUserId, myNewReview);
      },
      child: Text("Submit Review"));
}

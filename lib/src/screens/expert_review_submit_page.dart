import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/review.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ExpertReviewSubmitPage extends StatefulWidget {
  final DocumentWrapper<UserInformation> _authorUser;
  final DocumentWrapper<UserInformation> _expertUser;

  ExpertReviewSubmitPage(this._authorUser, this._expertUser);

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
      onPressed: () async {
        final myNewReview = Review(
            widget._authorUser.documentType.authUid,
            widget._authorUser.documentType.firstName,
            widget._authorUser.documentType.lastName,
            widget._expertUser.documentType.authUid,
            _review,
            _rating);

        await myNewReview.put();
      },
      child: Text("Submit Review"));
}

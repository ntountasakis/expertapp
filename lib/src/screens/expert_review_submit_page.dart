import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_information.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ExpertReviewSubmitPage extends StatefulWidget {
  // TODO, we'll need the author user for deleting/modyfing existing review
  final String _authorUserUid;
  final DocumentWrapper<UserMetadata> _expertUserMetadata;

  ExpertReviewSubmitPage(this._authorUserUid, this._expertUserMetadata);

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
                buildSubmit(context),
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

  void _reviewSubmitAcknowledgmentDialog(BuildContext context, String dialogText) async {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              dialogText,
              style: TextStyle(fontSize: 18),
            ),
            children: [
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      "Ok",
                      style: TextStyle(fontSize: 18),
                    ),
                  ))
            ],
          );
        });
  }

  Widget buildSubmit(BuildContext context) => ElevatedButton(
      style: style,
      onPressed: () async {
        String dialogText = await onSubmitReview(
            reviewedUid: widget._expertUserMetadata.documentId,
            reviewText: _review,
            reviewRating: _rating);
        _reviewSubmitAcknowledgmentDialog(context, dialogText);
      },
      child: Text("Submit Review"));
}

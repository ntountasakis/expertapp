import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

class ExpertReviewSubmitPage extends StatefulWidget {
  final String currentUserId;
  final String expertUserId;
  final AppLifecycle lifecycle;

  ExpertReviewSubmitPage(
      {required this.currentUserId, required this.expertUserId,
      required this.lifecycle});

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

  void _reviewSubmitAcknowledgmentDialog(
      BuildContext context, String dialogText) async {
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
                  onPressed: () async {
                    await widget.lifecycle.refreshOwedBalance();
                    context.goNamed(Routes.HOME);
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

  Widget buildSubmit(
      BuildContext context, DocumentWrapper<UserMetadata> expertUserMetadata) {
    return ElevatedButton(
        style: style,
        onPressed: () async {
          String dialogText = await onSubmitReview(
              reviewedUid: expertUserMetadata.documentId,
              reviewText: _review,
              reviewRating: _rating);
          _reviewSubmitAcknowledgmentDialog(context, dialogText);
        },
        child: Text("Submit Review"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit a Review"),
      ),
      body: FutureBuilder<DocumentWrapper<UserMetadata>?>(
          future: UserMetadata.get(widget.expertUserId),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentWrapper<UserMetadata>?> snapshot) {
            if (snapshot.hasData) {
              final expertUserMetadata = snapshot.data;
              return Form(
                key: formKey,
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    buildTextReview(),
                    const SizedBox(height: 16),
                    buildNumericalRating(),
                    const SizedBox(height: 16),
                    buildSubmit(context, expertUserMetadata!),
                  ],
                ),
              );
            }
            return CircularProgressIndicator();
          }),
    );
  }
}

import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../call_server/call_server_model.dart';

class UserViewReviewSubmitPage extends StatefulWidget {
  final String currentUserId;
  final String expertUserId;
  final AppLifecycle lifecycle;

  UserViewReviewSubmitPage(
      {required this.currentUserId,
      required this.expertUserId,
      required this.lifecycle});

  @override
  State<UserViewReviewSubmitPage> createState() =>
      _UserViewReviewSubmitPageState();
}

class _UserViewReviewSubmitPageState extends State<UserViewReviewSubmitPage> {
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
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              dialogText,
              style: TextStyle(fontSize: 18),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () async {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
    final model = Provider.of<CallServerModel>(context, listen: false);
    CallSummaryUtil.postCallGoHome(context, model);
  }

  Widget buildSubmit(BuildContext context,
      DocumentWrapper<PublicExpertInfo> publicExpertInfo) {
    return ElevatedButton(
        style: style,
        onPressed: () async {
          String dialogText = await onSubmitReview(
              reviewedUid: publicExpertInfo.documentId,
              reviewText: _review,
              reviewRating: _rating);
          _reviewSubmitAcknowledgmentDialog(context, dialogText);
        },
        child: Text("Submit Review for Expert"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit a Review"),
      ),
      body: FutureBuilder<DocumentWrapper<PublicExpertInfo>?>(
          future: PublicExpertInfo.get(
              uid: widget.expertUserId, fromSignUpFlow: false),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
            if (snapshot.hasData) {
              final publicExpertInfo = snapshot.data;
              return Form(
                key: formKey,
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    buildTextReview(),
                    const SizedBox(height: 16),
                    buildNumericalRating(),
                    const SizedBox(height: 16),
                    buildSubmit(context, publicExpertInfo!),
                  ],
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}

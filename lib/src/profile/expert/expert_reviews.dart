import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/profile/expert/expert_review.dart';
import 'package:flutter/material.dart';

class ExpertReviews extends StatefulWidget {
  final DocumentWrapper<UserMetadata> _expertUserMetadata;
  const ExpertReviews(this._expertUserMetadata);

  @override
  State<ExpertReviews> createState() => _ExpertReviewsState();
}

class _ExpertReviewsState extends State<ExpertReviews> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ExpertReview.getStream(widget._expertUserMetadata),
        builder: (BuildContext context, AsyncSnapshot<Iterable<ExpertReview>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return snapshot.data!.elementAt(index);
                });
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

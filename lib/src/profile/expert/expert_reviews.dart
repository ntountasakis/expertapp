import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/expert/expert_review.dart';
import 'package:flutter/material.dart';

class ExpertReviews extends StatefulWidget {
  final DocumentWrapper<PublicExpertInfo> _publicExpertInfo;
  const ExpertReviews(this._publicExpertInfo);

  @override
  State<ExpertReviews> createState() => _ExpertReviewsState();
}

class _ExpertReviewsState extends State<ExpertReviews> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ExpertReview.getStream(widget._publicExpertInfo),
        builder: (BuildContext context,
            AsyncSnapshot<Iterable<ExpertReview>> snapshot) {
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

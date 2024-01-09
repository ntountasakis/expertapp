import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class Review {
  final String authorUid;
  final String authorFirstName;
  final String authorLastName;
  final String reviewedUid;
  final String reviewText;
  final double rating;

  Review(this.authorUid, this.authorFirstName, this.authorLastName,
      this.reviewedUid, this.reviewText, this.rating);

  Review.fromJson(Map<String, dynamic> json)
      : this(
          json['authorUid'] as String,
          json['authorFirstName'] as String,
          json['authorLastName'] as String,
          json['reviewedUid'] as String,
          json['reviewText'] as String,
          json['rating'] + 0.0,
        );

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'authorUid': authorUid,
      'authorFirstName': authorFirstName,
      'authorLastName': authorLastName,
      'reviewedUid': reviewedUid,
      'reviewText': reviewText,
      'rating': rating,
    };
    return fieldsMap;
  }

  Future<DocumentWrapper<Review>> put() async {
    DocumentReference<Review> reviewRef = await _reviewRef().add(this);
    return DocumentWrapper(reviewRef.id, this);
  }

  static Stream<Iterable<DocumentWrapper<Review>>> getStream(String reviewedUid) {
    return _reviewRef()
        .where('reviewedUid', isEqualTo: reviewedUid)
        .snapshots()
        .map((QuerySnapshot<Review> collectionSnapshot) {
      return collectionSnapshot.docs
          .map((QueryDocumentSnapshot<Review> documentSnapshot) {
        return DocumentWrapper(documentSnapshot.id, documentSnapshot.data());
      });
    });
  }

  static CollectionReference<Review> _reviewRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.REVIEWS)
        .withConverter<Review>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              Review.fromJson(snapshot.data()!),
          toFirestore: (Review review, _) => review._toJson(),
        );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class UserMetadata {
  final String firstName;
  final String lastName;
  final String profilePicUrl;
  final double runningSumReviewRatings;
  final int numReviews;

  UserMetadata(this.firstName, this.lastName, this.profilePicUrl,
      this.runningSumReviewRatings, this.numReviews);

  UserMetadata.fromJson(Map<String, dynamic> json)
      : this(
          json['firstName'] as String,
          json['lastName'] as String,
          json['profilePicUrl'] as String,
          json['runningSumReviewRatings'] + 0.0,
          json['numReviews'] as int,
        );

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'firstName': firstName,
      'lastName': lastName,
      'profilePicUrl': profilePicUrl,
      'runningSumReviewRatings': runningSumReviewRatings,
      'numReviews': numReviews,
    };
    return fieldsMap;
  }

  double getAverageReviewRating() {
    if (numReviews == 0) return 0;
    return runningSumReviewRatings / numReviews;
  }

  static Future<DocumentWrapper<UserMetadata>?> get(
      String documentId) async {
    DocumentSnapshot snapshot =
        await _userMetadataRef().doc(documentId).get();
    if (snapshot.exists) {
      return DocumentWrapper(documentId, snapshot.data() as UserMetadata);
    }
    return null;
  }

  static Stream<Iterable<DocumentWrapper<UserMetadata>>> getStream() {
    return _userMetadataRef()
        .snapshots()
        .map((QuerySnapshot<UserMetadata> collectionSnapshot) {
      return collectionSnapshot.docs
          .map((QueryDocumentSnapshot<UserMetadata> documentSnapshot) {
        return DocumentWrapper(documentSnapshot.id, documentSnapshot.data());
      });
    });
  }

  static CollectionReference<UserMetadata> _userMetadataRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.USER_METADATA)
        .withConverter<UserMetadata>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              UserMetadata.fromJson(snapshot.data()!),
          toFirestore: (UserMetadata userMetadata, _) => userMetadata._toJson(),
        );
  }
}

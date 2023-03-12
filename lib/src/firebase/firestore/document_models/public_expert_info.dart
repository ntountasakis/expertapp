import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_availability.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class PublicExpertInfo {
  final String firstName;
  final String lastName;
  final String description;
  final String majorExpertCategory;
  final String minorExpertCategory;
  String profilePicUrl;
  final double runningSumReviewRatings;
  final int numReviews;
  ExpertAvailability availability;
  final bool inCall;

  PublicExpertInfo(
      this.firstName,
      this.lastName,
      this.description,
      this.majorExpertCategory,
      this.minorExpertCategory,
      this.profilePicUrl,
      this.runningSumReviewRatings,
      this.numReviews,
      this.availability,
      this.inCall);

  PublicExpertInfo.fromJson(Map<String, dynamic> json)
      : this(
            json['firstName'] as String,
            json['lastName'] as String,
            json['description'] as String,
            json['majorExpertCategory'] as String,
            json['minorExpertCategory'] as String,
            json['profilePicUrl'] as String,
            json['runningSumReviewRatings'] + 0.0,
            json['numReviews'] as int,
            ExpertAvailability.fromJson(json['availability']),
            json['inCall'] as bool);

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'firstName': firstName,
      'lastName': lastName,
      'description': description,
      'profilePicUrl': profilePicUrl,
      'runningSumReviewRatings': runningSumReviewRatings,
      'numReviews': numReviews,
      'availability': availability.toJson(),
      'inCall': inCall,
    };
    return fieldsMap;
  }

  String fullName() {
    return firstName + ' ' + lastName;
  }

  double getAverageReviewRating() {
    if (numReviews == 0) return 0;
    return runningSumReviewRatings / numReviews;
  }

  Future<void> updateProfilePic(String aDocumentId, String url) async {
    profilePicUrl = url;
    await update(aDocumentId);
  }

  static Future<DocumentWrapper<PublicExpertInfo>?> get(
      String documentId) async {
    DocumentSnapshot snapshot = await _userMetadataRef().doc(documentId).get();
    if (snapshot.exists) {
      return DocumentWrapper(documentId, snapshot.data() as PublicExpertInfo);
    }
    return null;
  }

  Future<void> update(String documentId) async {
    await _userMetadataRef().doc(documentId).set(this);
  }

  static Stream<DocumentWrapper<PublicExpertInfo>> getStreamForUser(
      String uid) {
    return _userMetadataRef()
        .doc(uid)
        .snapshots()
        .map((DocumentSnapshot<PublicExpertInfo> documentSnapshot) {
      return DocumentWrapper(documentSnapshot.id, documentSnapshot.data()!);
    });
  }

  static Stream<Iterable<DocumentWrapper<PublicExpertInfo>>> getStream() {
    return _userMetadataRef()
        .snapshots()
        .map((QuerySnapshot<PublicExpertInfo> collectionSnapshot) {
      return collectionSnapshot.docs
          .map((QueryDocumentSnapshot<PublicExpertInfo> documentSnapshot) {
        return DocumentWrapper(documentSnapshot.id, documentSnapshot.data());
      });
    });
  }

  static PublicExpertInfo test(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      return new PublicExpertInfo.fromJson(snapshot.data()!);
    }
    throw Exception('DocumentSnapshot data is null');
  }

  static CollectionReference<PublicExpertInfo> _userMetadataRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.PUBLIC_EXPERT_INFO)
        .withConverter<PublicExpertInfo>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              test(snapshot),
          toFirestore: (PublicExpertInfo userMetadata, _) =>
              userMetadata._toJson(),
        );
  }
}

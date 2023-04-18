import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_availability.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';
import 'package:expertapp/src/util/string_casing_extension.dart';

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
  final bool isOnline;

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
      this.inCall,
      this.isOnline);

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
          json['inCall'] as bool,
          json['isOnline'] as bool,
        );

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
      'isOnline': isOnline,
    };
    return fieldsMap;
  }

  String majorCategory() {
    return majorExpertCategory != "" ? majorExpertCategory.capitalize() : "";
  }

  String minorCategory() {
    return minorExpertCategory;
  }

  String shortName() {
    return firstName + ' ' + lastName[0] + '.';
  }

  double getAverageReviewRating() {
    if (numReviews == 0) return 0;
    return runningSumReviewRatings / numReviews;
  }

  Future<void> updateProfilePic(
      {required String uid,
      required String url,
      required bool fromSignUpFlow}) async {
    profilePicUrl = url;
    await update(uid: uid, fromSignUpFlow: fromSignUpFlow);
  }

  static Future<DocumentWrapper<PublicExpertInfo>?> get(
      {required String uid, required bool fromSignUpFlow}) async {
    DocumentSnapshot snapshot =
        await _userMetadataRef(fromSignUpFlow: fromSignUpFlow).doc(uid).get();
    if (snapshot.exists) {
      return DocumentWrapper(uid, snapshot.data() as PublicExpertInfo);
    }
    return null;
  }

  Future<void> update(
      {required String uid, required bool fromSignUpFlow}) async {
    await _userMetadataRef(fromSignUpFlow: fromSignUpFlow).doc(uid).set(this);
  }

  static Stream<DocumentWrapper<PublicExpertInfo>> getStreamForUser(
      {required String uid, required bool fromSignUpFlow}) {
    return _userMetadataRef(fromSignUpFlow: fromSignUpFlow)
        .doc(uid)
        .snapshots()
        .map((DocumentSnapshot<PublicExpertInfo> documentSnapshot) {
      return DocumentWrapper(documentSnapshot.id, documentSnapshot.data()!);
    });
  }

  static Stream<Iterable<DocumentWrapper<PublicExpertInfo>>> getStream(
      {required bool fromSignUpFlow}) {
    return _userMetadataRef(fromSignUpFlow: fromSignUpFlow)
        .orderBy('majorExpertCategory')
        .orderBy('minorExpertCategory')
        .orderBy('firstName')
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

  static CollectionReference<PublicExpertInfo> _userMetadataRef(
      {required bool fromSignUpFlow}) {
    return FirebaseFirestore.instance
        .collection(fromSignUpFlow
            ? CollectionPaths.PUBLIC_EXPERT_INFO_STAGING
            : CollectionPaths.PUBLIC_EXPERT_INFO)
        .withConverter<PublicExpertInfo>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              test(snapshot),
          toFirestore: (PublicExpertInfo userMetadata, _) =>
              userMetadata._toJson(),
        );
  }
}

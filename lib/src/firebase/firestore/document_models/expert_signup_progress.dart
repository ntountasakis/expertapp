import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class ExpertSignupProgress {
  final bool updatedProfilePic;
  final bool updatedProfileDescription;
  final bool updatedExpertCategory;
  final bool updatedCallRate;
  final bool updatedAvailability;
  final bool updatedSmsPreferences;

  ExpertSignupProgress(
      this.updatedProfilePic,
      this.updatedProfileDescription,
      this.updatedExpertCategory,
      this.updatedCallRate,
      this.updatedAvailability,
      this.updatedSmsPreferences,
      );

  ExpertSignupProgress.fromJson(Map<String, dynamic> json)
      : this(
          json['updatedProfilePic'] as bool,
          json['updatedProfileDescription'] as bool,
          json['updatedExpertCategory'] as bool,
          json['updatedCallRate'] as bool,
          json['updatedAvailability'] as bool,
          json['updatedSmsPreferences'] as bool,
        );

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'updatedProfilePic': updatedProfilePic,
      'updatedProfileDescription': updatedProfileDescription,
      'updatedExpertCategory': updatedExpertCategory,
      'updatedCallRate': updatedCallRate,
      'updatedAvailability': updatedAvailability,
      'updatedSmsPreferences': updatedSmsPreferences,
    };
    return fieldsMap;
  }

  static Stream<DocumentWrapper<ExpertSignupProgress>?> getStreamForUser(
      {required String uid}) {
    return _signupProgressRef()
        .doc(uid)
        .snapshots()
        .map((DocumentSnapshot<ExpertSignupProgress> documentSnapshot) {
      return DocumentWrapper(documentSnapshot.id, documentSnapshot.data()!);
    });
  }

  static Future<DocumentWrapper<ExpertSignupProgress>?> get(
      {required String uid}) async {
    DocumentSnapshot snapshot = await _signupProgressRef().doc(uid).get();
    if (snapshot.exists) {
      return DocumentWrapper(uid, snapshot.data() as ExpertSignupProgress);
    }
    return null;
  }

  static ExpertSignupProgress test(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      return new ExpertSignupProgress.fromJson(snapshot.data()!);
    }
    throw Exception('DocumentSnapshot data is null');
  }

  static CollectionReference<ExpertSignupProgress> _signupProgressRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.EXPERT_SIGNUP_PROGRESS)
        .withConverter<ExpertSignupProgress>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              test(snapshot),
          toFirestore: (ExpertSignupProgress userMetadata, _) =>
              userMetadata._toJson(),
        );
  }
}

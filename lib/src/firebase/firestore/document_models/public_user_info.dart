import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class PublicUserInfo {
  final String firstName;
  final String lastName;

  PublicUserInfo(
    this.firstName,
    this.lastName,
  );

  PublicUserInfo.fromJson(Map<String, dynamic> json)
      : this(
          json['firstName'] as String,
          json['lastName'] as String,
        );

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'firstName': firstName,
      'lastName': lastName,
    };
    return fieldsMap;
  }

  static Future<DocumentWrapper<PublicUserInfo>?> get(String documentId) async {
    DocumentSnapshot snapshot =
        await _PublicUserInfoRef().doc(documentId).get();
    if (snapshot.exists) {
      return DocumentWrapper(documentId, snapshot.data() as PublicUserInfo);
    }
    return null;
  }

  static PublicUserInfo test(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      return new PublicUserInfo.fromJson(snapshot.data()!);
    }
    throw Exception('DocumentSnapshot data is null');
  }

  static CollectionReference<PublicUserInfo> _PublicUserInfoRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.PUBLIC_USER_INFO)
        .withConverter<PublicUserInfo>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              test(snapshot),
          toFirestore: (PublicUserInfo userMetadata, _) =>
              userMetadata._toJson(),
        );
  }
}

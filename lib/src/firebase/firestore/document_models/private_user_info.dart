import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class PrivateUserInfo {
  final String email;
  final String stripeCustomerId;
  final String stripeConnectedId;

  PrivateUserInfo(
    this.email,
    this.stripeCustomerId,
    this.stripeConnectedId,
  );

  PrivateUserInfo.fromJson(Map<String, dynamic> json)
      : this(
          json['email'] as String,
          json['stripeCustomerId'] as String,
          json['stripeConnectedId'] as String,
        );

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'email': email,
      'stripeCustomerId': stripeCustomerId,
      'stripeConnectedId': stripeConnectedId,
    };
    return fieldsMap;
  }

  static Future<DocumentWrapper<PrivateUserInfo>?> get(
      String documentId) async {
    DocumentSnapshot snapshot =
        await _privateUserInfoRef().doc(documentId).get();
    if (snapshot.exists) {
      return DocumentWrapper(documentId, snapshot.data() as PrivateUserInfo);
    }
    return null;
  }

  static PrivateUserInfo test(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.data() != null) {
      return new PrivateUserInfo.fromJson(snapshot.data()!);
    }
    throw Exception('DocumentSnapshot data is null');
  }

  static CollectionReference<PrivateUserInfo> _privateUserInfoRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.PRIVATE_USER_INFO)
        .withConverter<PrivateUserInfo>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              test(snapshot),
          toFirestore: (PrivateUserInfo userMetadata, _) =>
              userMetadata._toJson(),
        );
  }
}

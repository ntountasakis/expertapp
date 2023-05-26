import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class PrivateUserInfo {
  final String email;
  final String stripeCustomerId;
  final String stripeConnectedId;
  final String phoneNumber;
  final String phoneNumberDialCode;
  final String phoneNumberIsoCode;
  final bool consentsToSms;

  PrivateUserInfo(
    this.email,
    this.stripeCustomerId,
    this.stripeConnectedId,
    this.phoneNumber,
    this.phoneNumberDialCode,
    this.phoneNumberIsoCode,
    this.consentsToSms,
  );

  PrivateUserInfo.fromJson(Map<String, dynamic> json)
      : this(
          json['email'] as String,
          json['stripeCustomerId'] as String,
          json['stripeConnectedId'] as String,
          json['phoneNumber'] as String,
          json['phoneNumberDialCode'] as String,
          json['phoneNumberIsoCode'] as String,
          json['consentsToSms'] as bool,
        );

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'email': email,
      'stripeCustomerId': stripeCustomerId,
      'stripeConnectedId': stripeConnectedId,
      'phoneNumber': phoneNumber,
      'phoneNumberDialCode': phoneNumberDialCode,
      'phoneNumberIsoCode': phoneNumberIsoCode,
      'consentsToSms': consentsToSms,
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

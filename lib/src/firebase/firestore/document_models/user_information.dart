import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class UserInformation {
  final String firstName;
  final String lastName;

  UserInformation(this.firstName, this.lastName);

  UserInformation.fromJson(Map<String, dynamic> json)
      : this(
          json['firstName'] as String,
          json['lastName'] as String,
        );

  Map<String, dynamic> _toJson() {
    return {'firstName': firstName, 'lastName': lastName};
  }

  Future<void> set(String documentId) async {
    return _userInformationRef().doc(documentId).set(this);
  }

  static Future<DocumentWrapper<UserInformation>?> get(
      String documentId) async {
    DocumentSnapshot snapshot =
        await _userInformationRef().doc(documentId).get();
    if (snapshot.exists) {
      return DocumentWrapper(documentId, snapshot.data() as UserInformation);
    }
    return null;
  }

  static CollectionReference<UserInformation> _userInformationRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.USERS)
        .withConverter<UserInformation>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              UserInformation.fromJson(snapshot.data()!),
          toFirestore: (UserInformation userInfo, _) => userInfo._toJson(),
        );
  }
}

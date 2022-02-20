import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class UserInformation {
  final String authUid;
  final String firstName;
  final String lastName;
  late String? profilePicUrl;

  UserInformation(
      this.authUid, this.firstName, this.lastName, this.profilePicUrl);

  UserInformation.fromJson(Map<String, dynamic> json)
      : this(
          json['authToken'] as String,
          json['firstName'] as String,
          json['lastName'] as String,
          json.containsKey('profilePicUrl')
              ? json['profilePicUrl']! as String
              : null,
        );

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'authToken': authUid,
      'firstName': firstName,
      'lastName': lastName
    };
    if (profilePicUrl != null) {
      fieldsMap['profilePicUrl'] = profilePicUrl!;
    }
    return fieldsMap;
  }

  Future<DocumentWrapper<UserInformation>> put() async {
    DocumentReference<UserInformation> userInfoRef =
        await _userInformationRef().add(this);
    return DocumentWrapper(userInfoRef.id, this);
  }

  Future<void> set(String documentId) async {
    return _userInformationRef().doc(documentId).set(this);
  }

  static Future<DocumentWrapper<UserInformation>?> getByAuthToken(
      String authToken) async {
    QuerySnapshot querySnapshot = await _userInformationRef()
        .where('authToken', isEqualTo: authToken)
        .withConverter<UserInformation>(
            fromFirestore:
                (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
                    UserInformation.fromJson(snapshot.data()!),
            toFirestore: (UserInformation userInfo, _) => userInfo._toJson())
        .get();

    if (querySnapshot.size > 1) {
      throw Exception('Query for authToken: $authToken matches > 1 users');
    }

    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    String documentId = querySnapshot.docs.first.id;
    return DocumentWrapper(
        documentId, querySnapshot.docs.first.data() as UserInformation);
  }

  static Stream<Iterable<DocumentWrapper<UserInformation>>> getStream() {
    return _userInformationRef()
        .snapshots()
        .map((QuerySnapshot<UserInformation> collectionSnapshot) {
      return collectionSnapshot.docs
          .map((QueryDocumentSnapshot<UserInformation> documentSnapshot) {
        return DocumentWrapper(documentSnapshot.id, documentSnapshot.data());
      });
    });
  }

  static Future<UserInformation?> getDocument(String documentId) async {
    DocumentReference<UserInformation> userInfoRef =
        await _userInformationRef().doc(documentId);
    DocumentSnapshot<UserInformation> userInfoSnapshot =
        await userInfoRef.get();
    return userInfoSnapshot.data();
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class FcmToken {
  final String token;

  FcmToken(this.token);

  FcmToken.fromJson(Map<String, dynamic> json)
      : this(json['token'] as String);

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'token': token,
    };
    return fieldsMap;
  }

  Future<void> put(String documentId) async {
      await _tokenRef().doc(documentId).set(this);
  }

  static CollectionReference<FcmToken> _tokenRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.FCM_TOKENS)
        .withConverter<FcmToken>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              FcmToken.fromJson(snapshot.data()!),
          toFirestore: (FcmToken token, _) => token._toJson(),
        );
  }
}

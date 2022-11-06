import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class PaymentStatus {
  final int centsCollected;
  final int centsToCollect;
  final String status;
  final String transferGroup;
  final String uid;

  PaymentStatus(this.centsCollected, this.centsToCollect, this.status,
      this.transferGroup, this.uid);

  PaymentStatus.fromJson(Map<String, dynamic> json)
      : this(
          json['centsCollected'] as int,
          json['centsToCollect'] as int,
          json['status'] as String,
          json['transferGroup'] as String,
          json['uid'] as String,
        );

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'centsCollected': centsCollected,
      'centsToCollect': centsToCollect,
      'status': status,
      'transferGroup': transferGroup,
      'uid': uid,
    };
    return fieldsMap;
  }

  bool paymentComplete() {
    return centsCollected == centsToCollect;
  }

  static Future<DocumentWrapper<PaymentStatus>?> get(String documentId) async {
    DocumentSnapshot snapshot = await _paymentStatusRef().doc(documentId).get();
    if (snapshot.exists) {
      return DocumentWrapper(documentId, snapshot.data() as PaymentStatus);
    }
    return null;
  }

  static Stream<Iterable<DocumentWrapper<PaymentStatus>>> getStream(
      String currentUserId) {
    return _paymentStatusRef()
        .where("uid", isEqualTo: currentUserId)
        .snapshots()
        .map((QuerySnapshot<PaymentStatus> collectionSnapshot) {
      return collectionSnapshot.docs
          .map((QueryDocumentSnapshot<PaymentStatus> documentSnapshot) {
        return DocumentWrapper(documentSnapshot.id, documentSnapshot.data());
      });
    });
  }

  static CollectionReference<PaymentStatus> _paymentStatusRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.PAYMENT_STATUSES)
        .withConverter<PaymentStatus>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              PaymentStatus.fromJson(snapshot.data()!),
          toFirestore: (PaymentStatus status, _) => status._toJson(),
        );
  }
}

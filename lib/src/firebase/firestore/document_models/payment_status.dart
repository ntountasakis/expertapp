import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class PaymentStatus {
  final String uid;
  final int centsRequestedCapture;
  final int centsPaid;

  PaymentStatus(this.uid, this.centsRequestedCapture, this.centsPaid);

  PaymentStatus.fromJson(Map<String, dynamic> json)
      : this(
          json['uid'] as String,
          json['centsRequestedCapture'] as int,
          json['centsPaid'] as int,
        );

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'uid': uid,
      'centsRequestedCapture': centsRequestedCapture,
      'centsPaid': centsPaid,
    };
    return fieldsMap;
  }

  bool paymentComplete() {
    return centsRequestedCapture == centsPaid;
  }

  int amountOwedCents() {
    return centsPaid - centsRequestedCapture;
  }

  static Future<DocumentWrapper<PaymentStatus>?> get(String documentId) async {
    DocumentSnapshot snapshot = await _paymentStatusRef().doc(documentId).get();
    if (snapshot.exists) {
      return DocumentWrapper(documentId, snapshot.data() as PaymentStatus);
    }
    return null;
  }

  static Stream<Iterable<DocumentWrapper<PaymentStatus>>>
      getStreamOfPaymentsForUser(String currentUserId) {
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

  static Stream<DocumentWrapper<PaymentStatus?>> getStreamOfUpdatesForPayments(
      String paymentStatusId) {
    return _paymentStatusRef()
        .doc(paymentStatusId)
        .snapshots()
        .map((DocumentSnapshot<PaymentStatus> documentSnapshot) {
      return DocumentWrapper(documentSnapshot.id, documentSnapshot.data());
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class CallTransaction {
  final String callerUid;
  final String calledUid;
  final int expertRateCentsPerMinute;
  final int expertRateCentsCallStart;
  final String callerPaymentStatusId;
  final int callRequestTimeUtcMs;
  final int calledJoinTimeUtcMs;
  final int callEndTimeUtcMs;
  final int costOfCallCents;
  final int earnedTotalCents;
  final int lengthOfCallSec;

  CallTransaction(
      this.callerUid,
      this.calledUid,
      this.expertRateCentsPerMinute,
      this.expertRateCentsCallStart,
      this.callerPaymentStatusId,
      this.callRequestTimeUtcMs,
      this.calledJoinTimeUtcMs,
      this.callEndTimeUtcMs,
      this.costOfCallCents,
      this.earnedTotalCents,
      this.lengthOfCallSec);

  CallTransaction.fromJson(Map<String, dynamic> json)
      : this(
          json["callerUid"] as String,
          json["calledUid"] as String,
          json["expertRateCentsPerMinute"] as int,
          json["expertRateCentsCallStart"] as int,
          json["callerPaymentStatusId"] as String,
          json["callRequestTimeUtcMs"] as int,
          json["calledJoinTimeUtcMs"] as int,
          json["callEndTimeUtcMs"] as int,
          json["costOfCallCents"] as int,
          json["earnedTotalCents"] as int,
          (json["lengthOfCallSec"]).round(),
        );

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'callerUid': callerUid,
      'calledUid': calledUid,
      'expertRateCentsPerMinute': expertRateCentsPerMinute,
      'expertRateCentsCallStart': expertRateCentsCallStart,
      'callerPaymentStatusId': callerPaymentStatusId,
      'callRequestTimeUtcMs': callRequestTimeUtcMs,
      'calledJoinTimeUtcMs': calledJoinTimeUtcMs,
      'callEndTimeUtcMs': calledJoinTimeUtcMs,
      'costOfCallCents': costOfCallCents,
      'earnedTotalCents': earnedTotalCents,
      'lengthOfCallSec': lengthOfCallSec,
    };
    return fieldsMap;
  }

  static Future<DocumentWrapper<CallTransaction>?> get(
      String documentId) async {
    DocumentSnapshot snapshot =
        await _callTransactionRef().doc(documentId).get();
    if (snapshot.exists) {
      return DocumentWrapper(documentId, snapshot.data() as CallTransaction);
    }
    return null;
  }

  static Stream<DocumentWrapper<CallTransaction>> getStreamForTransaction(String documentId) {
    return _callTransactionRef()
        .doc(documentId)
        .snapshots()
        .map((DocumentSnapshot<CallTransaction> documentSnapshot) {
      return DocumentWrapper(documentSnapshot.id, documentSnapshot.data()!);
    });
  }

  static Stream<Iterable<DocumentWrapper<CallTransaction>>> getStreamForCaller(
      {required String callerUid}) {
    return _callTransactionRef()
        .where("callerUid", isEqualTo: callerUid)
        .orderBy("callEndTimeUtcMs", descending: true)
        .snapshots()
        .map((QuerySnapshot<CallTransaction> collectionSnapshot) {
      return collectionSnapshot.docs
          .map((QueryDocumentSnapshot<CallTransaction> documentSnapshot) {
        return DocumentWrapper(documentSnapshot.id, documentSnapshot.data());
      });
    });
  }

  static Stream<Iterable<DocumentWrapper<CallTransaction>>> getStreamForCalled(
      {required String calledUid}) {
    return _callTransactionRef()
        .where("calledUid", isEqualTo: calledUid)
        .orderBy("callEndTimeUtcMs", descending: true)
        .snapshots()
        .map((QuerySnapshot<CallTransaction> collectionSnapshot) {
      return collectionSnapshot.docs
          .map((QueryDocumentSnapshot<CallTransaction> documentSnapshot) {
        return DocumentWrapper(documentSnapshot.id, documentSnapshot.data());
      });
    });
  }

  static CollectionReference<CallTransaction> _callTransactionRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.CALL_TRANSACTIONS)
        .withConverter<CallTransaction>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              CallTransaction.fromJson(snapshot.data()!),
          toFirestore: (CallTransaction status, _) => status._toJson(),
        );
  }
}

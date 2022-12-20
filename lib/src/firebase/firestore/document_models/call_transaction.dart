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
  final int callEndTimeUtsMs;

  CallTransaction(
      this.callerUid,
      this.calledUid,
      this.expertRateCentsPerMinute,
      this.expertRateCentsCallStart,
      this.callerPaymentStatusId,
      this.callRequestTimeUtcMs,
      this.calledJoinTimeUtcMs,
      this.callEndTimeUtsMs);

  CallTransaction.fromJson(Map<String, dynamic> json)
      : this(
            json["callerUid"] as String,
            json["calledUid"] as String,
            json["expertRateCentsPerMinute"] as int,
            json["expertRateCentsCallStart"] as int,
            json["callerPaymentStatusId"] as String,
            json["callRequestTimeUtcMs"] as int,
            json["calledJoinTimeUtcMs"] as int,
            json["callEndTimeUtsMs"] as int);

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'callerUid': callerUid,
      'calledUid': calledUid,
      'expertRateCentsPerMinute': expertRateCentsPerMinute,
      'expertRateCentsCallStart': expertRateCentsCallStart,
      'callerPaymentStatusId': callerPaymentStatusId,
      'callRequestTimeUtcMs': callRequestTimeUtcMs,
      'calledJoinTimeUtcMs': calledJoinTimeUtcMs,
      'callEndTimeUtsMs': calledJoinTimeUtcMs,
    };
    return fieldsMap;
  }

  static Stream<Iterable<DocumentWrapper<CallTransaction>>> getStream(String currentUserId) {
    return _callTransactionRef()
        .where("callerUid", isEqualTo: currentUserId)
        .orderBy("callEndTimeUtsMs", descending: true)
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

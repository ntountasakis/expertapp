import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';
import 'package:expertapp/src/util/currency_util.dart';

class ExpertRate {
  final num centsPerMinute;
  final num centsCallStart;

  ExpertRate({required this.centsPerMinute, required this.centsCallStart});

  ExpertRate.fromJson(Map<String, dynamic> json)
      : this(
            centsPerMinute: json['centsPerMinute'] as num,
            centsCallStart: json['centsCallStart'] as num);

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'centsPerMinute': centsPerMinute,
      'centsCallStart': centsCallStart,
    };
    return fieldsMap;
  }

  String formattedStartCallFee() {
    return formattedRate(centsCallStart);
  }

  String formattedPerMinuteFee() {
    return formattedRate(centsPerMinute);
  }

  static Future<DocumentWrapper<ExpertRate>?> get(String documentId) async {
    DocumentSnapshot snapshot = await _expertRateRef().doc(documentId).get();
    if (snapshot.exists) {
      return DocumentWrapper(documentId, snapshot.data() as ExpertRate);
    }
    return null;
  }

  static Stream<DocumentWrapper<ExpertRate>?> getStream(
      String uid) {
    return _expertRateRef()
        .doc(uid)
        .snapshots()
        .map((DocumentSnapshot<ExpertRate> documentSnapshot) {
      return DocumentWrapper(documentSnapshot.id, documentSnapshot.data()!);
    });
  }

  static CollectionReference<ExpertRate> _expertRateRef() {
    return FirebaseFirestore.instance
        .collection(CollectionPaths.EXPERT_RATES)
        .withConverter<ExpertRate>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              ExpertRate.fromJson(snapshot.data()!),
          toFirestore: (ExpertRate expertRate, _) => expertRate._toJson(),
        );
  }
}

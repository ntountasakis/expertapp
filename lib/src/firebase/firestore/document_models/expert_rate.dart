import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';
import 'package:intl/intl.dart';

class ExpertRate {
  final num centsPerMinute;

  ExpertRate(this.centsPerMinute);

  ExpertRate.fromJson(Map<String, dynamic> json)
      : this(json['centsPerMinute'] as num);

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'centsPerMinute': centsPerMinute,
    };
    return fieldsMap;
  }

  String formattedRate() {
    final dollarFormat = new NumberFormat("#,##0.00", "en_US");
    int dollars = (centsPerMinute / 100).truncate();
    num cents = centsPerMinute % 100;
    num decimalAmount = dollars + (cents / 100);
    return '\$${dollarFormat.format(decimalAmount)} per minute';
  }

  static Future<DocumentWrapper<ExpertRate>?> get(String documentId) async {
    DocumentSnapshot snapshot = await _expertRateRef().doc(documentId).get();
    if (snapshot.exists) {
      return DocumentWrapper(documentId, snapshot.data() as ExpertRate);
    }
    return null;
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

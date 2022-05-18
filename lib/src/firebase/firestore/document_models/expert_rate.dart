import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/firestore_paths.dart';

class ExpertRate {
  final num dollarsPerMinute;

  ExpertRate(this.dollarsPerMinute);

  ExpertRate.fromJson(Map<String, dynamic> json)
      : this(json['dollarsPerMinute'] as num);

  Map<String, dynamic> _toJson() {
    var fieldsMap = {
      'dollarsPerMinute': dollarsPerMinute,
    };
    return fieldsMap;
  }

  String formattedRate() {
    if (dollarsPerMinute < 1) {
      double cents = (dollarsPerMinute - dollarsPerMinute.truncate()) * 100;
      return '₵${cents.truncate()} cents per minute';
    }
    return '\$${dollarsPerMinute.toStringAsFixed(2)} dollars per minute';
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

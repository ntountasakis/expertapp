import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';

class ExpertCallPreviewArguments {
  final DocumentWrapper<UserMetadata> selectedExpert;
  final DocumentWrapper<ExpertRate> expertRate;

  ExpertCallPreviewArguments(this.selectedExpert, this.expertRate);
}

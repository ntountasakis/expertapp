import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';

class ExpertProfileArguments {
  final DocumentWrapper<UserMetadata> selectedExpert;

  ExpertProfileArguments(this.selectedExpert);
}

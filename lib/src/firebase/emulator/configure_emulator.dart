import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

String localhostString() {
  return Platform.isAndroid ? '10.0.2.2' : 'localhost';
}

Future connectToFirebaseEmulator() async {
  await FirebaseAuth.instance.useAuthEmulator(localhostString(), 9000);
  FirebaseFunctions.instance.useFunctionsEmulator(localhostString(), 9001);
  FirebaseFirestore.instance.useFirestoreEmulator(localhostString(), 9002);
  await FirebaseStorage.instance.useStorageEmulator(localhostString(), 9004);
}

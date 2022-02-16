import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future connectToFirebaseEmulator() async {
  final localhostString = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  FirebaseDatabase.instance.useDatabaseEmulator(localhostString, 9003);
  await FirebaseStorage.instance.useStorageEmulator(localhostString, 9006);
  await FirebaseAuth.instance.useAuthEmulator(localhostString, 9000);
}

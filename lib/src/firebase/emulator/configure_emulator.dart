import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

Future connectToFirebaseEmulator() async {
  final localhostString = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  FirebaseDatabase.instance.setPersistenceEnabled(false);
  FirebaseDatabase.instance.useDatabaseEmulator(localhostString, 9000);
  await FirebaseAuth.instance.useAuthEmulator(localhostString, 9099);
}

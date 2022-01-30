import 'dart:io';

import 'package:expertapp/src/screens/auth_gate_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

const bool USE_FIREBASE_EMULATOR = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (USE_FIREBASE_EMULATOR) {
    _connectToFirebaseEmulator();
  }

  runApp(MyApp());
}

Future _connectToFirebaseEmulator() async {
  final localhostString = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  FirebaseDatabase.instance.useDatabaseEmulator(localhostString, 9000);
  await FirebaseAuth.instance.useAuthEmulator(localhostString, 9099);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: AuthGatePage(),
    );
  }
}

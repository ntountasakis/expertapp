import 'package:expertapp/firebase_options.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_update_rates_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MyTestApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new ExpertViewUpdateRatesPage(
          uid: "mpKZBT949r8LM9wkzIvfl6GQQ2OQ",
        ));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await connectToFirebaseEmulator();

  runApp(new MyTestApp());
}

import 'package:expertapp/firebase_options.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/screens/expert_view/expert_view_call_join_prompt_page.dart';
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
        home: new ExpertViewCallJoinPromptPage(
          transactionId: "",
          callerUserId: "US8xSI8IkEZH0TFrQPt7yA700lhR",
          expertRate: ExpertRate(centsCallStart: 80, centsPerMinute: 180),
          callJoinExpirationTimeUtcMs:
              DateTime.now().toUtc().millisecondsSinceEpoch + 50000,
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

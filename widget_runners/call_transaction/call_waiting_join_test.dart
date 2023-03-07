import 'package:expertapp/firebase_options.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/util/call_waiting_join.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../runner_util/widget_runner_util.dart';

class CallWaitingWrapper extends StatelessWidget {
  late DocumentWrapper<PublicExpertInfo> userMetadata;

  CallWaitingWrapper() {
    const url =
        "http://10.0.2.2:9004/expert-app-backend.appspot.com/profilePics/Portrait_Placeholder.png";

    final metadata = PublicExpertInfo(
        "", "", "", url, 0, 0, makeDefaultAvailability(), false);
    userMetadata = DocumentWrapper<PublicExpertInfo>("id", metadata);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Call Waiting"),
      ),
      body: CallWaitingJoin(
        onCancelCallTap: () => print("Cancel Call"),
        calledUserMetadata: userMetadata,
      ),
    );
  }
}

class MyTestApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new CallWaitingWrapper(),
    );
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

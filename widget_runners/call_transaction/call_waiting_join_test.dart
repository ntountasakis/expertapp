import 'package:expertapp/firebase_options.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_rate.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/transaction/client/widgets/call_waiting_join.dart';
import 'package:expertapp/src/screens/transaction/expert/call_transaction_expert_prompt.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class CallWaitingWrapper extends StatelessWidget {
  late DocumentWrapper<UserMetadata> userMetadata;

  CallWaitingWrapper() {
    const url =
        "http://10.0.2.2:9004/expert-app-backend.appspot.com/profilePics/Portrait_Placeholder.png";
    final metadata = UserMetadata("", "", url, 0, 0);
    userMetadata = DocumentWrapper<UserMetadata>("id", metadata);
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

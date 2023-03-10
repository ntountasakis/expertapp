import 'package:expertapp/firebase_options.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:expertapp/src/appbars/expert_view/expert_in_call_appbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

import '../runner_util/widget_runner_util.dart';

class MockCallServerModel extends Mock implements CallServerModel {}

CallServerModel buildModel() {
  final model = MockCallServerModel();

  final stripeFeePercent = 2.9;
  final stripeFlatFeeCents = 60;
  final platformFeePercent = 8.0;
  final rateStartCallCents = 180;
  final ratePerMinute = 240;

  final fees = ServerFeeBreakdowns(
      paymentProcessorPercentFee: stripeFeePercent,
      paymentProcessorCentsFlatFee: stripeFlatFeeCents,
      platformPercentFee: platformFeePercent,
      earnedCentsStartCall: rateStartCallCents,
      earnedCentsPerMinute: ratePerMinute);

  when(() => model.callLengthSeconds()).thenReturn(100);
  when(() => model.feeBreakdowns).thenReturn(fees);
  return model;
}

DocumentWrapper<PublicUserInfo> buildUser() {
  final user = PublicUserInfo(
    "Billy",
    "Bob",
  );

  return DocumentWrapper("abc", user);
}

class DummyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ExpertInCallAppbar(buildUser(), buildModel()),
      body: SizedBox(),
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
      home: new DummyWidget(),
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

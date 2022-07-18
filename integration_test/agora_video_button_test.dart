import 'dart:io';

import 'package:expertapp/src/agora/agora_video_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void onCameraMuteTap(bool aMuted) {}
void onMicMuteTap(bool aMuted) {}
void onEndCallTap() {}

var buttonState = AgoraVideoCallButtonState();

class VideoButtonWrapper extends StatelessWidget {
  final AgoraVideoCallButtonState buttonState;

  VideoButtonWrapper(this.buttonState);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
      ),
      body: Container(
          child: agoraVideoButtons(
              callButtonState: buttonState,
              onCameraMuteTap: onCameraMuteTap,
              onMicMuteTap: onMicMuteTap,
              onEndCalTap: onEndCallTap)),
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
      home: VideoButtonWrapper(buttonState),
    );
  }
}

void main() {
  testWidgets('View Agora Video Buttons', (tester) async {
    runApp(new MyTestApp());
    await tester.pumpAndSettle();
  });
}

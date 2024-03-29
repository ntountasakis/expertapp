import 'package:expertapp/src/agora/agora_video_controls.dart';
import 'package:flutter/material.dart';

import '../widget_runner_test_app.dart';

class VideoButtonWrapper extends StatefulWidget {
  VideoButtonWrapper();

  @override
  State<VideoButtonWrapper> createState() => _VideoButtonWrapperState();
}

class _VideoButtonWrapperState extends State<VideoButtonWrapper> {
  var buttonState = AgoraVideoCallButtonState();

  void onCameraMuteTap(bool aMuted) {
    setState(() {
      buttonState.videoMuted = aMuted;
    });
  }

  void onMicMuteTap(bool aMuted) {
    setState(() {
      buttonState.audioMuted = aMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
      ),
      body: Stack(children: [
        Center(
          child: SizedBox(
            height: 200,
            child: Container(
              color: Colors.blue,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 100,
            width: 150,
            child: Container(
              color: Colors.red,
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 0,
          child: agoraVideoButtons(
              callButtonState: buttonState,
              onCameraMuteTap: onCameraMuteTap,
              onMicMuteTap: onMicMuteTap,
              onEndCallTap: () => {},
              onChatButtonTap: () => {},
              context: context),
        ),
      ]),
    );
  }
}

void main() {
  runApp(new WidgetRunnerTestApp(new VideoButtonWrapper()));
}

import 'package:flutter/material.dart';

class AgoraVideoCallButtonState {
  bool videoEnabled = true;
  bool audioEnabled = true;
}

typedef void VideoCallButtonToggleTap(bool isDisabled);
typedef void VideoCallButtonEndTap();

Widget agoraCameraMuteButton(
    AgoraVideoCallButtonState buttonState, VideoCallButtonToggleTap onCameraMuteTap) {
  final MaterialColor cameraColor =
      buttonState.videoEnabled ? Colors.green : Colors.red;
  return IconButton(
    icon: Icon(
      Icons.camera_alt,
      size: 20,
      color: cameraColor,
    ),
    onPressed: () async {
      onCameraMuteTap(buttonState.videoEnabled);
    },
  );
}

Widget agoraMicMuteButton(
    AgoraVideoCallButtonState buttonState, VideoCallButtonToggleTap onMicMuteTap) {
  final MaterialColor micColor =
      buttonState.audioEnabled ? Colors.green : Colors.red;
  return IconButton(
    icon: Icon(
      Icons.mic,
      size: 20,
      color: micColor,
    ),
    onPressed: () async {
      onMicMuteTap(!buttonState.audioEnabled);
    },
  );
}

Widget agoraEndCallButton(VideoCallButtonEndTap onEndCalTap) {
  return IconButton(
    icon: Icon(
      Icons.call_end_rounded,
      size: 20,
      color: Colors.red,
    ),
    onPressed: () async {
      onEndCalTap();
    },
  );
}

Widget agoraVideoButtons({required AgoraVideoCallButtonState callButtonState,
required VideoCallButtonToggleTap onCameraMuteTap,
required VideoCallButtonToggleTap onMicMuteTap,
required VideoCallButtonEndTap onEndCalTap}) {
  return Row(
    children: [
      agoraCameraMuteButton(callButtonState, onCameraMuteTap),
      SizedBox(width: 20),
      agoraMicMuteButton(callButtonState, onMicMuteTap),
      SizedBox(width: 20),
      agoraEndCallButton(onEndCalTap)
    ],
  );
}

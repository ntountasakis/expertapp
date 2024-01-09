import 'package:expertapp/src/util/call_buttons.dart';
import 'package:flutter/material.dart';

class AgoraVideoCallButtonState {
  bool videoMuted = false;
  bool audioMuted = false;
}

typedef void VideoCallButtonToggleTap(bool isDisabled);

const videoButtonTextStyle = TextStyle(fontSize: 10);

Widget agoraCameraMuteButton(AgoraVideoCallButtonState buttonState,
    VideoCallButtonToggleTap onCameraMuteTap) {
  final IconData cameraIcon =
      buttonState.videoMuted ? Icons.videocam_off : Icons.videocam;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: Icon(
        cameraIcon,
        size: 25,
        color: Colors.grey.shade900,
      ),
      onPressed: () async {
        onCameraMuteTap(!buttonState.videoMuted);
      },
    ),
  );
}

Widget agoraMicMuteButton(AgoraVideoCallButtonState buttonState,
    VideoCallButtonToggleTap onMicMuteTap) {
  final IconData micIcon =
      buttonState.audioMuted ? Icons.mic_off_rounded : Icons.mic;
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: Icon(
        micIcon,
        size: 25,
        color: Colors.grey.shade900,
      ),
      onPressed: () async {
        onMicMuteTap(!buttonState.audioMuted);
      },
    ),
  );
}

Widget chatButton(VoidCallback onChatButtonTap) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.green,
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: Icon(
        Icons.chat_bubble_rounded,
        size: 25,
        color: Colors.white,
      ),
      onPressed: () async {
        onChatButtonTap();
      },
    ),
  );
}

Widget agoraVideoButtons(
    {required AgoraVideoCallButtonState callButtonState,
    required VideoCallButtonToggleTap onCameraMuteTap,
    required VideoCallButtonToggleTap onMicMuteTap,
    required VoidCallback onEndCallTap,
    required VoidCallback onChatButtonTap,
    required BuildContext context}) {
  return callButtonRow(context, [
    agoraCameraMuteButton(callButtonState, onCameraMuteTap),
    SizedBox(width: 20),
    agoraMicMuteButton(callButtonState, onMicMuteTap),
    SizedBox(width: 20),
    endCallButton(onEndCallTap),
    SizedBox(width: 20),
    chatButton(onChatButtonTap)
  ]);
}

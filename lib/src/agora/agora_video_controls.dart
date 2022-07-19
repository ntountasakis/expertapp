import 'package:flutter/material.dart';

class AgoraVideoCallButtonState {
  bool videoMuted = false;
  bool audioMuted = false;
}

typedef void VideoCallButtonToggleTap(bool isDisabled);
typedef void VideoCallButtonEndTap();

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

Widget agoraEndCallButton(VideoCallButtonEndTap onEndCalTap) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.red,
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: Icon(
        Icons.call_end_rounded,
        size: 25,
        color: Colors.white,
      ),
      onPressed: () async {
        onEndCalTap();
      },
    ),
  );
}

Widget agoraVideoButtons(
    {required AgoraVideoCallButtonState callButtonState,
    required VideoCallButtonToggleTap onCameraMuteTap,
    required VideoCallButtonToggleTap onMicMuteTap,
    required VideoCallButtonEndTap onEndCalTap,
    required BuildContext context}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    child: Center(
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            agoraCameraMuteButton(callButtonState, onCameraMuteTap),
            SizedBox(width: 20),
            agoraMicMuteButton(callButtonState, onMicMuteTap),
            SizedBox(width: 20),
            agoraEndCallButton(onEndCalTap)
          ],
        ),
      ),
    ),
  );
}

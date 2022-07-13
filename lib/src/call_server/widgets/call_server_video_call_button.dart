import 'package:expertapp/src/agora/agora_video_call.dart';
import 'package:expertapp/src/screens/video_call_page.dart';
import 'package:flutter/material.dart';

Widget buildVideoCallButton(BuildContext context, String currentUserId) {
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return ElevatedButton(
      style: style,
      onPressed: () {
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => VideoCallPage("debug", currentUserId)));
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AgoraVideoCall()));
      },
      child: const Text('Call Expert'),
    );
  }
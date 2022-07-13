import 'package:expertapp/src/agora/agora_video_call.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:flutter/material.dart';

Widget buildVideoCallButton(
    {required BuildContext context, required CallServerModel model}) {
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  if (model.agoraCredentials == null) {
    return Text("Awaiting Video Call Credentials");
  }
  final String agoraChannelName = model.agoraCredentials!.channelName;
  final String agoraToken = model.agoraCredentials!.token;
  final int agoraUid = model.agoraCredentials!.uid;
  return ElevatedButton(
    style: style,
    onPressed: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgoraVideoCall(
                agoraChannelName: agoraChannelName,
                agoraToken: agoraToken,
                agoraUid: agoraUid),
          ));
    },
    child: const Text('Call Expert'),
  );
}

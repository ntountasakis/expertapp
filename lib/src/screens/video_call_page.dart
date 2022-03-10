import 'package:agora_uikit/agora_uikit.dart';
import 'package:expertapp/src/agora/agora_app_id.dart';
import 'package:flutter/material.dart';

class VideoCallPage extends StatefulWidget {
  final String channelName;

  VideoCallPage(this.channelName);

  @override
  State<VideoCallPage> createState() =>
      _VideoCallPageState(AgoraAppId.ID, channelName);
}

class _VideoCallPageState extends State<VideoCallPage> {
  final AgoraClient agoraClient;

  _VideoCallPageState(appId, channelName)
      : agoraClient = AgoraClient(
            agoraConnectionData: AgoraConnectionData(
                appId: appId,
                channelName: channelName,
                tempToken: AgoraAppId.TEST_TOKEN),
            enabledPermission: [
              Permission.camera,
              Permission.microphone,
            ]);

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  void initAgora() async {
    await agoraClient.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call'),
      ),
      body: Stack(children: [
        AgoraVideoViewer(client: agoraClient),
        AgoraVideoButtons(client: agoraClient),
      ]),
    );
  }
}

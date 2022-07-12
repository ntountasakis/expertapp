import 'package:agora_uikit/agora_uikit.dart';
import 'package:expertapp/src/agora/agora_app_id.dart';
import 'package:flutter/material.dart';

class VideoCallPage extends StatefulWidget {
  final String channelName;
  final String currentUserId;

  VideoCallPage(this.channelName, this.currentUserId);

  @override
  State<VideoCallPage> createState() =>
      _VideoCallPageState(AgoraAppId.ID, channelName, currentUserId);
}

class _VideoCallPageState extends State<VideoCallPage> {
  final AgoraClient agoraClient;

  _VideoCallPageState(appId, channelName, currentUserId)
      : agoraClient = AgoraClient(
            agoraConnectionData: AgoraConnectionData(
                appId: appId,
                channelName: channelName,
                username: currentUserId,
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Video Call'),
        ),
        body: SafeArea(
          child: Stack(children: [
            AgoraVideoViewer(client: agoraClient),
            AgoraVideoButtons(client: agoraClient),
          ]),
        ),
      ),
    );
  }
}

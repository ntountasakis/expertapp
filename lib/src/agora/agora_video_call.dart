import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:expertapp/src/agora/agora_app_id.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraVideoCall extends StatefulWidget {
  final String agoraChannelName;
  final String agoraToken;
  final int agoraUid;

  AgoraVideoCall(
      {required this.agoraChannelName,
      required this.agoraToken,
      required this.agoraUid});

  @override
  _AgoraVideoCallState createState() => _AgoraVideoCallState();
}

class CallButtonState {
  bool videoEnabled = true;
  bool audioEnabled = true;
}

class _AgoraVideoCallState extends State<AgoraVideoCall> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  final buttonState = CallButtonState();

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = await RtcEngine.create(AgoraAppId.ID);
    await _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          log("local user $uid joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        userJoined: (int uid, int elapsed) {
          log("remote user $uid joined");
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          log("remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.joinChannel(
        widget.agoraToken, widget.agoraChannelName, null, widget.agoraUid);
  }

  Widget buildCameraButton() {
    final MaterialColor cameraColor =
        buttonState.videoEnabled ? Colors.green : Colors.red;
    return IconButton(
      icon: Icon(
        Icons.camera_alt,
        size: 20,
        color: cameraColor,
      ),
      onPressed: () async {
        await _engine.muteLocalVideoStream(!buttonState.videoEnabled);
        setState(() {
          buttonState.videoEnabled = !buttonState.videoEnabled;
        });
      },
    );
  }

  Widget buildMicButton() {
    final MaterialColor micColor =
        buttonState.audioEnabled ? Colors.green : Colors.red;
    return IconButton(
      icon: Icon(
        Icons.mic,
        size: 20,
        color: micColor,
      ),
      onPressed: () async {
        await _engine.muteLocalAudioStream(!buttonState.audioEnabled);
        setState(() {
          buttonState.audioEnabled = !buttonState.audioEnabled;
        });
      },
    );
  }

  Widget buildEndCallButton(BuildContext) {
    return IconButton(
      icon: Icon(
        Icons.call_end_rounded,
        size: 20,
        color: Colors.red,
      ),
      onPressed: () async {
        await _engine.destroy();
        Navigator.pop(context);
      },
    );
  }

  Widget buildVideoButtons(BuildContext context) {
    return Row(
      children: [
        buildCameraButton(),
        SizedBox(width: 20),
        buildMicButton(),
        SizedBox(width: 20),
        buildEndCallButton(context)
      ],
    );
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Video Call'),
        ),
        body: Stack(
          children: [
            Center(
              child: _remoteVideo(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 100,
                height: 150,
                child: Center(
                  child: _localUserJoined
                      ? RtcLocalView.SurfaceView()
                      : CircularProgressIndicator(),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              child: buildVideoButtons(context),
            )
          ],
        ),
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid!,
        channelId: widget.agoraChannelName,
      );
    } else {
      return Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:expertapp/src/agora/agora_app_id.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'agora_video_controls.dart';

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

class _AgoraVideoCallState extends State<AgoraVideoCall> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  final buttonState = AgoraVideoCallButtonState();

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

  void onCameraMuteTap(bool cameraMuted) async {
      await _engine.muteLocalVideoStream(!buttonState.videoEnabled);
      setState(() {
        buttonState.videoEnabled = cameraMuted;
      });
  }

  void onMicButtonMuteTap(bool cameraMuted) async {
    await _engine.muteLocalAudioStream(!buttonState.audioEnabled);
    setState(() {
      buttonState.audioEnabled = cameraMuted;
    });
  }

  void onEndCallTap() async {
      await _engine.destroy();
      Navigator.pop(context);
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
              child: agoraVideoButtons(callButtonState: buttonState,
                onCameraMuteTap: onCameraMuteTap,
              onMicMuteTap: onMicButtonMuteTap,
              onEndCalTap: onEndCallTap),
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

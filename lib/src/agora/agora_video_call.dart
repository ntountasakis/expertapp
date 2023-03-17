import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:expertapp/src/agora/agora_rtc_engine_wrapper.dart';
import 'package:expertapp/src/agora/agora_app_id.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'agora_video_controls.dart';

class AgoraVideoCall extends StatefulWidget {
  final String agoraChannelName;
  final String agoraToken;
  final int agoraUid;
  final VoidCallback onChatButtonTap;
  final VoidCallback onEndCallButtonTap;
  final RtcEngineWrapper engineWrapper;

  AgoraVideoCall(
      {required this.agoraChannelName,
      required this.agoraToken,
      required this.agoraUid,
      required this.onChatButtonTap,
      required this.onEndCallButtonTap,
      required this.engineWrapper});

  @override
  _AgoraVideoCallState createState() =>
      _AgoraVideoCallState(this.engineWrapper);
}

class _AgoraVideoCallState extends State<AgoraVideoCall> {
  final RtcEngineWrapper _engineWrapper;
  int? _remoteUid;
  bool _localUserJoined = false;
  final buttonState = AgoraVideoCallButtonState();

  _AgoraVideoCallState(this._engineWrapper);

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    _engineWrapper.setEngine(createAgoraRtcEngine());
    await _engineWrapper.engine.initialize(const RtcEngineContext(
      appId: AgoraAppId.ID,
    ));
    await _engineWrapper.engine.enableVideo();
    _engineWrapper.engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          log("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          log("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          log("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    final options = ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await _engineWrapper.engine.startPreview();
    await _engineWrapper.engine.joinChannel(
        token: widget.agoraToken,
        channelId: widget.agoraChannelName,
        uid: widget.agoraUid,
        options: options);
  }

  void onCameraMuteTap(bool cameraMuted) async {
    await _engineWrapper.engine.muteLocalVideoStream(cameraMuted);
    setState(() {
      buttonState.videoMuted = cameraMuted;
    });
  }

  void onMicButtonMuteTap(bool audioMuted) async {
    await _engineWrapper.engine.muteLocalAudioStream(audioMuted);
    setState(() {
      buttonState.audioMuted = audioMuted;
    });
  }

  void onEndCallTap() async {
    await _engineWrapper.teardown();
    widget.onEndCallButtonTap();
  }

  Widget localVideoView() {
    if (buttonState.videoMuted) {
      return Container(
        width: 100,
        height: 150,
        color: Colors.black,
      );
    }
    return Container(
      width: 100,
      height: 150,
      child: Center(
        child: _localUserJoined
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engineWrapper.engine,
                  canvas: VideoCanvas(uid: 0),
                ),
              )
            : CircularProgressIndicator(),
      ),
    );
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: localVideoView(),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            child: agoraVideoButtons(
                callButtonState: buttonState,
                onCameraMuteTap: onCameraMuteTap,
                onMicMuteTap: onMicButtonMuteTap,
                onEndCallTap: onEndCallTap,
                onChatButtonTap: widget.onChatButtonTap,
                context: context),
          )
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
          controller: VideoViewController.remote(
        rtcEngine: _engineWrapper.engine,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: RtcConnection(channelId: widget.agoraChannelName),
      ));
    } else {
      return Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}

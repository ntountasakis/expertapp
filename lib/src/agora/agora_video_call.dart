import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:expertapp/src/agora/agora_app_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:permission_handler/permission_handler.dart';

import 'agora_video_controls.dart';

class AgoraVideoCall extends StatefulWidget {
  final String agoraChannelName;
  final String agoraToken;
  final int agoraUid;
  final VoidCallback onChatButtonTap;
  final VoidCallback onEndCallButtonTap;
  final VoidCallback onRemoteUserJoined;

  AgoraVideoCall(
      {required this.agoraChannelName,
      required this.agoraToken,
      required this.agoraUid,
      required this.onChatButtonTap,
      required this.onEndCallButtonTap,
      required this.onRemoteUserJoined});

  @override
  _AgoraVideoCallState createState() => _AgoraVideoCallState();
}

class _AgoraVideoCallState extends State<AgoraVideoCall> {
  int? _remoteUid;
  bool _localUserJoined = false;
  final buttonState = AgoraVideoCallButtonState();
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = createAgoraRtcEngine();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      initAgora();
    });
  }

  @override
  void dispose() async {
    Future.delayed(Duration.zero, () async {
      await _engine.leaveChannel();
      await _engine.release();
    });
    super.dispose();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();
    await _engine.initialize(const RtcEngineContext(
      appId: AgoraAppId.ID,
    ));
    await _engine.enableVideo();
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          log("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          log("remote user $remoteUid joined");
          widget.onRemoteUserJoined();
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

    await _engine.startPreview();
    await _engine.joinChannel(
        token: widget.agoraToken,
        channelId: widget.agoraChannelName,
        uid: widget.agoraUid,
        options: options);
  }

  void onCameraMuteTap(bool cameraMuted) async {
    await _engine.muteLocalVideoStream(cameraMuted);
    setState(() {
      buttonState.videoMuted = cameraMuted;
    });
  }

  void onMicButtonMuteTap(bool audioMuted) async {
    await _engine.muteLocalAudioStream(audioMuted);
    setState(() {
      buttonState.audioMuted = audioMuted;
    });
  }

  void onEndCallTap() async {
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
                  rtcEngine: _engine,
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
        rtcEngine: _engine,
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

import 'dart:async';
import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_connection_establisher.dart';
import 'package:expertapp/src/call_server/call_server_error_reason.dart';
import 'package:expertapp/src/call_server/call_server_message_listener.dart';
import 'package:expertapp/src/call_server/call_server_message_producer.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:expertapp/src/version/app_version.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc_or_grpcweb.dart';

class CallServerManager {
  final String currentUserId;
  final String otherUserId;
  final _callEstablisher = CallServerConnectionEstablisher();
  final _serverMessageProducer = CallServerMessageProducer();
  late CallServerMessageListener _serverMessageListener =
      CallServerMessageListener();
  late Stream<ServerMessageContainer> _serverMessageStream;
  late StreamSubscription<ServerMessageContainer>
      _serverMessageStreamSubscription;

  CallServerManager({required this.currentUserId, required this.otherUserId});

  void initiateCall(BuildContext context) {
    _connect(context, true);
    _beginCall(context);
  }

  void joinCall(
      {required BuildContext context, required String callTransactionId}) {
    _connect(context, false);
    _joinCall(context, callTransactionId);
  }

  void _connect(BuildContext context, bool isCaller) {
    _serverMessageStream = _callEstablisher.connect(
        _serverMessageProducer.messageProducerStream(),
        currentUserId,
        isCaller);
    _serverMessageListener.onConnect(context);
    _serverMessageStreamSubscription = _serverMessageStream.listen(
        _serverMessageListener.onMessage,
        onError: this._onError,
        onDone: this._onDone);
  }

  Future<void> requestDisconnectFromServer() async {
    final disconnectRequest = ClientCallDisconnectRequest(uid: currentUserId);
    final messageContainer =
        new ClientMessageContainer(callDisconnectRequest: disconnectRequest);
    _serverMessageProducer.sendMessage(messageContainer);
  }

  Future<void> manuallyDisconnectFromServer() async {
    return _serverMessageProducer.shutdown();
  }

  void _onError(Object error) {
    log('On Error ${error}');

    if (error is GrpcError) {
      if (error.code == StatusCode.unavailable) {
        _serverMessageListener.onError(
            "Server is down for maintenance. Please try again later",
            CallServerErrorReason.SERVER_DOWN);
      } else if (error.message != null) {
        _serverMessageListener.onError(
            error.message!, CallServerErrorReason.SERVER_ERROR);
      } else {
        _serverMessageListener.onError("Please contact us if issue persists.",
            CallServerErrorReason.SERVER_ERROR);
      }
    }
  }

  Future<void> _onDone() async {
    log('On done');
    _serverMessageProducer.shutdown();
    await _serverMessageStreamSubscription.cancel();
    _serverMessageListener.onDisconnect();
  }

  void _beginCall(BuildContext context) {
    final initiateRequest = ClientCallInitiateRequest(
      callerUid: currentUserId,
      calledUid: otherUserId,
      version: AppVersion.version,
    );
    final messageContainer =
        new ClientMessageContainer(callInitiateRequest: initiateRequest);
    _serverMessageProducer.sendMessage(messageContainer);
    log('Initiate call request sent');
  }

  void _joinCall(BuildContext context, String callTransactionId) {
    final joinRequest = ClientCallJoinRequest(
      callTransactionId: callTransactionId,
      joinerUid: currentUserId,
      version: AppVersion.version,
    );
    final messageContainer =
        new ClientMessageContainer(callJoinRequest: joinRequest);
    _serverMessageProducer.sendMessage(messageContainer);
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_connection_establisher.dart';
import 'package:expertapp/src/call_server/call_server_message_listener.dart';
import 'package:expertapp/src/call_server/call_server_message_producer.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:flutter/material.dart';

class CallServerManager {
  final _callEstablisher = CallServerConnectionEstablisher();
  final _serverMessageListener = CallServerMessageListener();
  final _serverMessageProducer = CallServerMessageProducer();
  final String currentUserId;
  final String otherUserId;
  late Stream<ServerMessageContainer> _serverMessageStream;
  late StreamSubscription<ServerMessageContainer>
      _serverMessageStreamSubscription;

  CallServerManager({required this.currentUserId, required this.otherUserId});

  void initiateCall(BuildContext context) {
    _connect(context);
    _beginCall(context);
  }

  void joinCall(
      {required BuildContext context, required String callTransactionId}) {
    _connect(context);
    _joinCall(context, callTransactionId);
  }

  void _connect(BuildContext context) {
    _serverMessageStream = _callEstablisher
        .connect(_serverMessageProducer.messageProducerStream());
    _serverMessageListener.onConnect(context);

    _serverMessageStreamSubscription = _serverMessageStream.listen(
        _serverMessageListener.onMessage,
        onError: this._onError,
        onDone: this._onDone);
  }

  void disconnect() async {
    await _serverMessageProducer.shutdown();
    _serverMessageStreamSubscription.cancel();
  }

  void _onError(Object error) {
    log('On Error ${error}');
  }

  void _onDone() {
    log('On done');
    _serverMessageListener.onDisconnect();
  }

  void _beginCall(BuildContext context) {
    final initiateRequest = ClientCallInitiateRequest(
        callerUid: currentUserId, calledUid: otherUserId);
    final messageContainer =
        new ClientMessageContainer(callInitiateRequest: initiateRequest);
    _serverMessageProducer.sendMessage(messageContainer);
  }

  void _joinCall(BuildContext context, String callTransactionId) {
    final joinRequest = ClientCallJoinRequest(
        callTransactionId: callTransactionId, joinerUid: currentUserId);
    final messageContainer =
        new ClientMessageContainer(callJoinRequest: joinRequest);
    _serverMessageProducer.sendMessage(messageContainer);
  }
}

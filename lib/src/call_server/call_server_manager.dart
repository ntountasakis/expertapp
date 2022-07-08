import 'dart:async';
import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_connection_establisher.dart';
import 'package:expertapp/src/call_server/call_server_message_listener.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:flutter/material.dart';

class CallServerManager {
  final _callEstablisher = CallServerConnectionEstablisher();
  final _serverMessageListener = CallServerMessageListener();
  late Stream<ServerMessageContainer> _serverMessageStream;
  late StreamSubscription<ServerMessageContainer>
      _serverMessageStreamSubscription;

  void connect(
      {required BuildContext context,
      required String currentUserId,
      required String calledUserId}) {
    _serverMessageStream = _callEstablisher.call(
        context: context,
        currentUserId: currentUserId,
        calledUserId: calledUserId);
    _serverMessageListener.onConnect(context);

    _serverMessageStreamSubscription = _serverMessageStream.listen(
        _serverMessageListener.onMessage,
        onError: this._onError,
        onDone: this._onDone);
  }

  void disconnect() {
    _serverMessageStreamSubscription.cancel();
  }

  void _onError(Object error) {
    log('On Error ${error}');
  }

  void _onDone() {
    log('On done');
    _serverMessageListener.onDisconnect();
  }
}

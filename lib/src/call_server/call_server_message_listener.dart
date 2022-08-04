import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallServerMessageListener {
  late CallServerModel _model;

  void onConnect(BuildContext context) {
    _model = Provider.of<CallServerModel>(context, listen: false);
    _model.onConnected();
  }

  void onMessage(ServerMessageContainer aMessage) {
    if (aMessage.hasServerCallRequestResponse()) {
      final response = aMessage.serverCallRequestResponse;
      if (!response.success) {
        log("Error from call server ${response.errorMessage}");
        _model.onErrored(response.errorMessage);
      }
    } else if (aMessage.hasServerAgoraCredentials()) {
      _model.onAgoraCredentials(aMessage.serverAgoraCredentials);
    } else if (aMessage.hasServerCallBeginPaymentInitiate()) {
      _model.onServerCallBeginPaymentInitiate(
          aMessage.serverCallBeginPaymentInitiate);
    } else {
      throw new Exception('''Unexpected ServerResponseContainer messageType 
      on call request ${aMessage.whichMessageWrapper()}''');
    }
  }

  void onDisconnect() {
    _model.onDisconnected();
  }
}

import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallServerMessageListener {
  late BuildContext connectedContext;

  void onConnect(BuildContext context) {
    connectedContext = context;
    Provider.of<CallServerModel>(context, listen: false).onConnected();
  }

  void onMessage(ServerMessageContainer aMessage) {
    CallServerModel model =
        Provider.of<CallServerModel>(connectedContext, listen: false);
    if (aMessage.hasServerCallJoinOrRequestResponse()) {
      final response = aMessage.serverCallJoinOrRequestResponse;
      if (!response.success) {
        log("Error from call server ${response.errorMessage}");
        model.onErrored(response.errorMessage);
      } else {
        model.onServerCallJoinOrRequestResponse(response);
      }
    } else if (aMessage.hasServerAgoraCredentials()) {
      model.onAgoraCredentials(aMessage.serverAgoraCredentials);
    } else if (aMessage.hasServerFeeBreakdowns()) {
      model.onFeeBreakdowns(aMessage.serverFeeBreakdowns);
    } else if (aMessage.hasServerCallBeginPaymentPreAuth()) {
      model.onServerCallBeginPaymentPreAuth(
          aMessage.serverCallBeginPaymentPreAuth);
    } else if (aMessage.hasServerCallBeginPaymentPreAuthResolved()) {
      model.onServerCallBeginPaymentPreAuthResolved(
          aMessage.serverCallBeginPaymentPreAuthResolved);
    } else if (aMessage.hasServerCounterpartyJoinedCall()) {
      model.onServerCounterpartyJoinedCall(
          aMessage.serverCounterpartyJoinedCall);
    } else if (aMessage.hasServerCallSummary()) {
      model.onServerCallSummary(aMessage.serverCallSummary);
    } else {
      throw new Exception('''Unexpected ServerResponseContainer messageType 
      on call request ${aMessage.whichMessageWrapper()}''');
    }
  }

  void onError(String errorMessage) {
    Provider.of<CallServerModel>(connectedContext, listen: false)
        .onErrored(errorMessage);
  }

  void onDisconnect() {
    Provider.of<CallServerModel>(connectedContext, listen: false)
        .onDisconnected();
  }
}

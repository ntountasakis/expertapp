import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:flutter/material.dart';

class CallServerModel extends ChangeNotifier {
  String _errorMessage = "";
  String _callTransactionId = "";
  ServerAgoraCredentials? _agoraCredentials;
  ServerFeeBreakdowns? _feeBreakdowns;
  ServerCallSummary? _callSummary;
  late CallServerPaymentPromptModel _callBeginPaymentPromptModel;

  CallServerConnectionState _connectionState =
      CallServerConnectionState.UNCONNECTED;

  CallServerCounterpartyConnectionState _counterpartyConnectionState =
      CallServerCounterpartyConnectionState.DISCONNECTED;

  CallServerConnectionState get callConnectionState => _connectionState;
  String get errorMsg => _errorMessage;
  String get callTransactionId => _callTransactionId;
  ServerAgoraCredentials? get agoraCredentials => _agoraCredentials;
  ServerFeeBreakdowns? get feeBreakdowns => _feeBreakdowns;
  ServerCallSummary? get callSummary => _callSummary;

  CallServerPaymentPromptModel get callPaymentPromptModel =>
      _callBeginPaymentPromptModel;

  CallServerCounterpartyConnectionState get callCounterpartyConnectionState =>
      _counterpartyConnectionState;

  int _msEpochOfCounterpartyConnected = 0;
  int callJoinTimeExpiryUtcMs = 0;
  int secMaxCallLength = 0;

  CallServerModel() {
    _callBeginPaymentPromptModel =
        new CallServerPaymentPromptModel(notifyListeners);
  }

  int callLengthSeconds() {
    if (_msEpochOfCounterpartyConnected == 0) return 0;
    return ((DateTime.now().millisecondsSinceEpoch -
                _msEpochOfCounterpartyConnected) /
            1000)
        .round();
  }

  void reset() {
    _errorMessage = "";
    _callTransactionId = "";
    _agoraCredentials = null;
    _feeBreakdowns = null;
    _callSummary = null;
    _callBeginPaymentPromptModel =
        new CallServerPaymentPromptModel(notifyListeners);
    _connectionState = CallServerConnectionState.UNCONNECTED;
    _counterpartyConnectionState =
        CallServerCounterpartyConnectionState.DISCONNECTED;
    _msEpochOfCounterpartyConnected = 0;
    callJoinTimeExpiryUtcMs = 0;
  }

  void onConnected() {
    _connectionState = CallServerConnectionState.CONNECTED;
    notifyListeners();
  }

  void onDisconnected() {
    _connectionState = CallServerConnectionState.DISCONNECTED;
    notifyListeners();
  }

  void onErrored(String aErrorMessage) {
    _errorMessage = aErrorMessage;
    _connectionState = CallServerConnectionState.ERRORED;
    notifyListeners();
  }

  void onServerCallJoinOrRequestResponse(
      ServerCallJoinOrRequestResponse response) {
    _callTransactionId = response.callTransactionId;
    secMaxCallLength = response.secondsCallAuthorizedFor;
    notifyListeners();
  }

  void onAgoraCredentials(ServerAgoraCredentials agoraCredentials) {
    _agoraCredentials = agoraCredentials;
    notifyListeners();
  }

  void onFeeBreakdowns(ServerFeeBreakdowns feeBreakdowns) {
    _feeBreakdowns = feeBreakdowns;
    notifyListeners();
  }

  Future<void> onServerCallBeginPaymentPreAuth(
      ServerCallBeginPaymentPreAuth callBeginPaymentPreAuth) async {
    await _callBeginPaymentPromptModel.onPaymentDetails(
      stripeCustomerId: callBeginPaymentPreAuth.customerId,
      clientSecret: callBeginPaymentPreAuth.clientSecret,
      ephemeralKey: callBeginPaymentPreAuth.ephemeralKey,
      centsRequestedAuthorized:
          callBeginPaymentPreAuth.centsRequestedAuthorized,
    );
    notifyListeners();
  }

  void onServerCallBeginPaymentPreAuthResolved(
      ServerCallBeginPaymentPreAuthResolved response) {
    _callBeginPaymentPromptModel.onPaymentComplete();
    callJoinTimeExpiryUtcMs = response.joinCallTimeExpiryUtcMs.toInt();
    notifyListeners();
  }

  void onServerCounterpartyJoinedCall(ServerCounterpartyJoinedCall joinedCall) {
    _counterpartyConnectionState = CallServerCounterpartyConnectionState.JOINED;
    _msEpochOfCounterpartyConnected = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  void onServerCallSummary(ServerCallSummary callSummary) {
    log("onServerCallSummary: " + callSummary.toString());
    _callSummary = callSummary;
    notifyListeners();
  }
}

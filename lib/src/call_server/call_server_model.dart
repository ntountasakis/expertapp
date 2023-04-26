import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_error_reason.dart';
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

  CallServerErrorReason _errorReason = CallServerErrorReason.NOT_ERRORED;

  CallServerCounterpartyConnectionState _counterpartyConnectionState =
      CallServerCounterpartyConnectionState.DISCONNECTED;

  CallServerConnectionState get callConnectionState => _connectionState;
  CallServerErrorReason get callErrorReason => _errorReason;
  String get errorMsg => _errorMessage;
  String get callTransactionId => _callTransactionId;
  ServerAgoraCredentials? get agoraCredentials => _agoraCredentials;
  ServerFeeBreakdowns? get feeBreakdowns => _feeBreakdowns;
  ServerCallSummary? get callSummary => _callSummary;

  CallServerPaymentPromptModel get callPaymentPromptModel =>
      _callBeginPaymentPromptModel;

  CallServerCounterpartyConnectionState get callCounterpartyConnectionState =>
      _counterpartyConnectionState;

  int _callStartUtcMs = 0;
  int callJoinTimeExpiryUtcMs = 0;
  int secMaxCallLength = 0;

  CallServerModel() {
    _callBeginPaymentPromptModel =
        new CallServerPaymentPromptModel(notifyListeners);
  }

  int callElapsedSeconds() {
    if (_callStartUtcMs == 0) return 0;
    return ((DateTime.now().toUtc().millisecondsSinceEpoch - _callStartUtcMs) /
            1000)
        .round();
  }

  int callRemainingSeconds() {
    if (secMaxCallLength == 0) return 0;
    return secMaxCallLength - callElapsedSeconds();
  }

  bool callReady() {
    return callCounterpartyConnectionState ==
        CallServerCounterpartyConnectionState.READY_TO_START_CALL;
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
    _errorReason = CallServerErrorReason.NOT_ERRORED;
    _callStartUtcMs = 0;
    callJoinTimeExpiryUtcMs = 0;
  }

  void onConnected() {
    _connectionState = CallServerConnectionState.CONNECTED;
    notifyListeners();
  }

  void onDisconnected() {
    if (_connectionState != CallServerConnectionState.ERRORED) {
      _connectionState = CallServerConnectionState.DISCONNECTED;
      notifyListeners();
    }
  }

  void onErrored(String aErrorMessage, CallServerErrorReason aErrorReason) {
    _errorMessage = aErrorMessage;
    _connectionState = CallServerConnectionState.ERRORED;
    _errorReason = aErrorReason;
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
    _counterpartyConnectionState =
        CallServerCounterpartyConnectionState.WAITING_FOR_READY;
    notifyListeners();
  }

  void onServerCallSummary(ServerCallSummary callSummary) {
    log("onServerCallSummary: " + callSummary.toString());
    _callSummary = callSummary;
    notifyListeners();
  }

  void onServerBothPartiesReadyForCall(
      ServerBothPartiesReadyForCall serverBothPartiesReadyForCall) {
    _callStartUtcMs = serverBothPartiesReadyForCall.callStartUtcMs.toInt();
    _counterpartyConnectionState =
        CallServerCounterpartyConnectionState.READY_TO_START_CALL;
    notifyListeners();
  }
}

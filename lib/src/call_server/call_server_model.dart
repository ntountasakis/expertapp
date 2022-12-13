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
  CallServerPaymentPromptModel _callBeginPaymentPromptModel =
      new CallServerPaymentPromptModel();
  CallServerPaymentPromptModel _callTerminatePaymentPromptModel =
      new CallServerPaymentPromptModel();

  CallServerConnectionState _connectionState =
      CallServerConnectionState.DISCONNECTED;

  CallServerCounterpartyConnectionState _counterpartyConnectionState =
      CallServerCounterpartyConnectionState.DISCONNECTED;

  CallServerConnectionState get callConnectionState => _connectionState;
  String get errorMsg => _errorMessage;
  String get callTransactionId => _callTransactionId;
  ServerAgoraCredentials? get agoraCredentials => _agoraCredentials;
  ServerFeeBreakdowns? get feeBreakdowns => _feeBreakdowns;
  CallServerPaymentPromptModel get callBeginPaymentPromptModel =>
      _callBeginPaymentPromptModel;
  CallServerPaymentPromptModel get callTerminatePaymentPromptModel =>
      _callTerminatePaymentPromptModel;

  CallServerCounterpartyConnectionState get callCounterpartyConnectionState =>
      _counterpartyConnectionState;

  int _msEpochOfCounterpartyConnected = 0;
  int _msEpochCounterpartyDisconnected = 0;

  int callLengthSeconds() {
    if (_msEpochOfCounterpartyConnected == 0) return 0;
    if (_msEpochCounterpartyDisconnected != 0) {
      return ((_msEpochCounterpartyDisconnected -
                  _msEpochOfCounterpartyConnected) /
              1000)
          .round();
    }
    return ((DateTime.now().millisecondsSinceEpoch -
                _msEpochOfCounterpartyConnected) /
            1000)
        .round();
  }

  void reset() {
    _errorMessage = "";
    _callTransactionId = "";
    _agoraCredentials;
    _callBeginPaymentPromptModel = new CallServerPaymentPromptModel();
    _callTerminatePaymentPromptModel = new CallServerPaymentPromptModel();
    _connectionState = CallServerConnectionState.DISCONNECTED;
    _counterpartyConnectionState =
        CallServerCounterpartyConnectionState.DISCONNECTED;
    _msEpochOfCounterpartyConnected = 0;
    _msEpochCounterpartyDisconnected = 0;
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
  }

  void onAgoraCredentials(ServerAgoraCredentials agoraCredentials) {
    _agoraCredentials = agoraCredentials;
    notifyListeners();
  }

  void onFeeBreakdowns(ServerFeeBreakdowns feeBreakdowns) {
    _feeBreakdowns = feeBreakdowns;
    notifyListeners();
  }

  Future<void> onServerCallBeginPaymentInitiate(
      ServerCallBeginPaymentInitiate callBeginPaymentInitiate) async {
    await _callBeginPaymentPromptModel.onPaymentDetails(
        stripeCustomerId: callBeginPaymentInitiate.customerId,
        clientSecret: callBeginPaymentInitiate.clientSecret,
        ephemeralKey: callBeginPaymentInitiate.ephemeralKey);
    notifyListeners();
  }

  void onServerCallBeginPaymentInitiateResolved() {
    _callBeginPaymentPromptModel.onPaymentComplete();
    notifyListeners();
  }

  Future<void> onServerCallTerminatePaymentInitiate(
      ServerCallTerminatePaymentInitiate callTerminatePaymentInitiate) async {
    await _callTerminatePaymentPromptModel.onPaymentDetails(
        stripeCustomerId: callTerminatePaymentInitiate.customerId,
        clientSecret: callTerminatePaymentInitiate.clientSecret,
        ephemeralKey: callTerminatePaymentInitiate.ephemeralKey);
    notifyListeners();
  }

  void onServerCallTerminatePaymentInitiateResolved() {
    _callTerminatePaymentPromptModel.onPaymentComplete();
    notifyListeners();
  }

  void onServerCounterpartyJoinedCall() {
    _counterpartyConnectionState = CallServerCounterpartyConnectionState.JOINED;
    _msEpochOfCounterpartyConnected = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  void onServerCounterpartyLeftCall() {
    _counterpartyConnectionState = CallServerCounterpartyConnectionState.LEFT;
    _msEpochCounterpartyDisconnected = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }
}

import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:flutter/material.dart';

class CallServerModel extends ChangeNotifier {
  String _errorMessage = "";
  String _callTransactionId = "";
  ServerAgoraCredentials? _agoraCredentials;
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
  CallServerPaymentPromptModel get callBeginPaymentPromptModel =>
      _callBeginPaymentPromptModel;
  CallServerPaymentPromptModel get callTerminatePaymentPromptModel =>
      _callTerminatePaymentPromptModel;

  CallServerCounterpartyConnectionState get callCounterpartyConnectionState =>
      _counterpartyConnectionState;

  void reset() {
    _errorMessage = "";
    _callTransactionId = "";
    _agoraCredentials;
    _callBeginPaymentPromptModel = new CallServerPaymentPromptModel();
    _callTerminatePaymentPromptModel = new CallServerPaymentPromptModel();
    _connectionState = CallServerConnectionState.DISCONNECTED;
    _counterpartyConnectionState =
        CallServerCounterpartyConnectionState.DISCONNECTED;
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

  void onServerCallBeginPaymentInitiate(
      ServerCallBeginPaymentInitiate callBeginPaymentInitiate) {
    _callBeginPaymentPromptModel.onPaymentDetails(
        stripeCustomerId: callBeginPaymentInitiate.customerId,
        clientSecret: callBeginPaymentInitiate.clientSecret,
        ephemeralKey: callBeginPaymentInitiate.ephemeralKey);
    notifyListeners();
  }

  void onServerCallBeginPaymentInitiateResolved() {
    _callBeginPaymentPromptModel.onPaymentComplete();
    notifyListeners();
  }

  void onServerCallTerminatePaymentInitiate(
      ServerCallTerminatePaymentInitiate callTerminatePaymentInitiate) {
    _callTerminatePaymentPromptModel.onPaymentDetails(
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
    notifyListeners();
  }

  void onServerCounterpartyLeftCall() {
    _counterpartyConnectionState = CallServerCounterpartyConnectionState.LEFT;
    notifyListeners();
  }
}

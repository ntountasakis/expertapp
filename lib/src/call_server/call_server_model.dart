import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_payment_prompt_model.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:flutter/material.dart';

class CallServerModel extends ChangeNotifier {
  String _errorMessage = "";
  String _callTransactionId = "";
  ServerAgoraCredentials? _agoraCredentials;
  CallServerPaymentPromptModel _callBeginPaymentPromptModel =
      new CallServerPaymentPromptModel();

  CallServerConnectionState _connectionState =
      CallServerConnectionState.DISCONNECTED;

  CallServerConnectionState get callConnectionState => _connectionState;
  String get errorMsg => _errorMessage;
  String get callTransactionId => _callTransactionId;
  ServerAgoraCredentials? get agoraCredentials => _agoraCredentials;
  CallServerPaymentPromptModel get callBeginPaymentPromptModel =>
      _callBeginPaymentPromptModel;

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

  void onServerCallRequestResponse(ServerCallRequestResponse response) {
    _callTransactionId = response.callTransactionId;
  }

  void onAgoraCredentials(ServerAgoraCredentials agoraCredentials) {
    _agoraCredentials = agoraCredentials;
    notifyListeners();
  }

  void onServerCallBeginPaymentInitiate(
      ServerCallBeginPaymentInitiate callBeginPaymentInitiate) {
    _callBeginPaymentPromptModel.onPaymentDetails(callBeginPaymentInitiate);
    notifyListeners();
  }

  void onServerCallBeginPaymentInitiateResolved() {
    _callBeginPaymentPromptModel.onPaymentComplete();
    notifyListeners();
  }
}

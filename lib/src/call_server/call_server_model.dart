import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:flutter/material.dart';

class CallServerModel extends ChangeNotifier {
  String _errorMessage = "";
  ServerAgoraCredentials? _agoraCredentials;
  ServerCallBeginPaymentInitiate? _callBeginPaymentInitiate;

  CallServerConnectionState _connectionState =
      CallServerConnectionState.DISCONNECTED;

  CallServerConnectionState get callConnectionState => _connectionState;
  String get errorMsg => _errorMessage;
  ServerAgoraCredentials? get agoraCredentials => _agoraCredentials;
  ServerCallBeginPaymentInitiate? get callBeginPaymentInitiate => _callBeginPaymentInitiate;

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

  void onAgoraCredentials(ServerAgoraCredentials agoraCredentials) {
    _agoraCredentials = agoraCredentials;
    notifyListeners();
  }

  void onServerCallBeginPaymentInitiate(
      ServerCallBeginPaymentInitiate callBeginPaymentInitiate) {
    _callBeginPaymentInitiate = callBeginPaymentInitiate;
    notifyListeners();
  }
}

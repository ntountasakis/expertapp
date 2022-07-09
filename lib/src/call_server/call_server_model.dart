import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:flutter/material.dart';

class CallServerModel extends ChangeNotifier {
  String _errorMessage = "";
  CallServerConnectionState _connectionState =
      CallServerConnectionState.DISCONNECTED;

  CallServerConnectionState get callConnectionState => _connectionState;
  String get errorMsg => _errorMessage;

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
}

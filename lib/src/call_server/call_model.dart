import 'package:expertapp/src/call_server/call_connection_state.dart';
import 'package:flutter/material.dart';

class CallModel extends ChangeNotifier {
  String _errorMessage = "";
  CallConnectionState _connectionState = CallConnectionState.DISCONNECTED;

  CallConnectionState get callConnectionState => _connectionState;
  String get errorMsg => _errorMessage;

  void onCallRequest() {
    _connectionState = CallConnectionState.CONNECTING;
    notifyListeners();
  }

  void onConnected() {
    _connectionState = CallConnectionState.CONNECTED;
    notifyListeners();
  }

  void onDisconnected() {
    _connectionState = CallConnectionState.DISCONNECTED;
    notifyListeners();
  }

  void onErrored(String aErrorMessage) {
    _errorMessage = aErrorMessage;
    _connectionState = CallConnectionState.ERRORED;
    notifyListeners();
  }
}

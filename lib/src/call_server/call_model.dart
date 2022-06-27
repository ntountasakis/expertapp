import 'package:expertapp/src/call_server/call_connection_state.dart';
import 'package:flutter/material.dart';

class CallModel extends ChangeNotifier {
  CallConnectionState connectionState = CallConnectionState.DISCONNECTED;

  CallConnectionState get callConnectionState => connectionState;

  void onCallRequest() {
    connectionState = CallConnectionState.CONNECTING;
    notifyListeners();
  }

  void onConnected() {
    connectionState = CallConnectionState.CONNECTED;
    notifyListeners();
  }

  void onDisconnected() {
    connectionState = CallConnectionState.DISCONNECTED;
    notifyListeners();
  }
}

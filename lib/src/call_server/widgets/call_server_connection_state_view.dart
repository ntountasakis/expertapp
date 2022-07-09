  import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:flutter/material.dart';

Widget callServerConnectionStateView(CallServerModel model) {
    final state = model.callConnectionState;
    switch (state) {
      case CallServerConnectionState.DISCONNECTED:
        return Text("DISCONNECTED");
      case CallServerConnectionState.CONNECTED:
        return Text("CONNECTED");
      case CallServerConnectionState.ERRORED:
        return Text("Call Error: ${model.errorMsg}");
    }
  }
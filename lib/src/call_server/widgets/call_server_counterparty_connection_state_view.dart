import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:flutter/material.dart';

import '../call_server_model.dart';

Widget callServerCounterpartyConnectionStateView(CallServerModel model) {
  final state = model.callCounterpartyConnectionState;
  switch (state) {
    case CallServerCounterpartyConnectionState.DISCONNECTED:
      return Text("COUNTERPARY DISCONNECTED");
    case CallServerCounterpartyConnectionState.JOINED:
      return Text("COUNTERPARY JOINED");
    case CallServerCounterpartyConnectionState.LEFT:
      return Text("COUNTERPARY LEFT");
  }
}

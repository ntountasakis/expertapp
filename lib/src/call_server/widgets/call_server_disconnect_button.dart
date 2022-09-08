import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:flutter/material.dart';

Widget callServerDisconnectButton(
    BuildContext context, CallServerManager manager, CallServerModel model) {
  return ElevatedButton(
      onPressed: () async {
        manager.terminateCall(model.callTransactionId);
        await manager.disconnect();
        log('EndCallButton: call disconnected');
        Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
      },
      child: Text("End Call"));
}

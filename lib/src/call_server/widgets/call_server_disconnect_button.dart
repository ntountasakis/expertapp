import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:flutter/material.dart';

Widget callServerDisconnectButton(
    BuildContext context, CallServerManager manager) {
  return ElevatedButton(
      onPressed: () async {
        await manager.disconnect();
        log('EndCallButton: call disconnected');
        Navigator.pop(context);
      },
      child: Text("End Call"));
}

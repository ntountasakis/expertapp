import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:flutter/material.dart';

class CallClientSummary extends StatelessWidget {
  final CallServerManager callServerManager;

  const CallClientSummary({required this.callServerManager});

  Widget exitCallFlowButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          await callServerManager.disconnect();
          Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
        },
        child: Text("Exit Call Flow"));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(children: [
        exitCallFlowButton(context),
      ]),
    );
  }
}

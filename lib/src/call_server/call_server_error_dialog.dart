import 'package:expertapp/src/call_server/call_server_error_reason.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:flutter/material.dart';

void showCallServerErrorDialog(BuildContext context, CallServerModel model,
    Function(CallServerModel model) onDismissed) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(model.callErrorReason == CallServerErrorReason.SERVER_DOWN
              ? "Come back later"
              : "There's been an error"),
          content: Text(model.errorMsg),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                onDismissed(model);
              },
            )
          ],
        );
      });
}

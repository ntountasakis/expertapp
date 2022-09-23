import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:flutter/material.dart';

Widget callServerWrapUpCallButton(BuildContext context, CallServerModel model,
    Function(BuildContext, CallServerModel) navigateOnPress) {
  return ElevatedButton(
      onPressed: () async {
        navigateOnPress(context, model);
      },
      child: Text("Wrap Up Call"));
}

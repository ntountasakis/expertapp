import 'package:flutter/material.dart';

Widget callServerWrapUpCallButton(
  BuildContext context, Function(BuildContext) navigateOnPress) {
  return ElevatedButton(
      onPressed: () async {
        navigateOnPress(context);
      },
      child: Text("Wrap Up Call"));
}

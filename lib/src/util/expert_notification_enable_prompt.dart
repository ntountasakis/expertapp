import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void promptForNotificationEnable(BuildContext context) async {
  final isNotificationPermantlyDenied =
      await Permission.notification.isPermanentlyDenied;
  final isNotificationDenied = await Permission.notification.isDenied;
  if (isNotificationDenied || isNotificationPermantlyDenied) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enable notifications to answer incoming calls"),
            actions: [
              TextButton(
                child: Text("Enable notifications"),
                onPressed: () async {
                  await openAppSettings();
                },
              )
            ],
          );
        });
  }
}

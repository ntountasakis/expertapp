import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> promptNotifications(BuildContext context) async {
  final notificationsGranted = await Permission.notification.isGranted;
  if (!notificationsGranted) {
    final title = "Enable notifications to answer incoming calls";
    final prompt = "Enable notifications";
    await showSettingsDialog(context, "Notifications", title, prompt);
  }
}

Future<bool> promptCamera(BuildContext context) async {
  return promptForPhoneDevice(context, Permission.camera, "Camera");
}

Future<bool> promptCameraAndMicrophone(BuildContext context) async {
  final cameraIsGranted = await Permission.camera.request().isGranted;
  final micIsGranted = await Permission.microphone.request().isGranted;
  if (cameraIsGranted && micIsGranted) {
    return true;
  }
  final deviceName = !cameraIsGranted && !micIsGranted
      ? "Camera and Microphone"
      : !cameraIsGranted
          ? "Camera"
          : "Microphone";
  await showSettingsDialog(context, deviceName, null, null);
  return false;
}

Future<bool> promptForPhoneDevice(
    BuildContext context, Permission device, String deviceName) async {
  final status = await device.request();
  if (status == PermissionStatus.granted) {
    return true;
  }
  showSettingsDialog(context, deviceName, null, null);
  return false;
}

Future<void> showSettingsDialog(BuildContext context, String deviceName,
    String? title, String? prompt) async {
  final titleString = title == null ? "$deviceName access is required" : title;
  final promptString = prompt == null ? "Enable $deviceName access" : prompt;
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleString),
          actions: [
            TextButton(
              child: Center(child: Text(promptString)),
              onPressed: () async {
                await openAppSettings();
                Navigator.pop(context);
              },
            )
          ],
        );
      });
}

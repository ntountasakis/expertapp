import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
  await showSettingsDialog(context, deviceName);
  return false;
}

Future<bool> promptForPhoneDevice(
    BuildContext context, Permission device, String deviceName) async {
  final status = await device.request();
  if (status == PermissionStatus.granted) {
    return true;
  }
  showSettingsDialog(context, deviceName);
  return false;
}

Future<void> showSettingsDialog(BuildContext context, String deviceName) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$deviceName access is required"),
          actions: [
            TextButton(
              child: Center(child: Text("Enable $deviceName access")),
              onPressed: () async {
                await openAppSettings();
                Navigator.pop(context);
              },
            )
          ],
        );
      });
}

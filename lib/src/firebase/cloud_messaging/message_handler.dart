import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void initFirebaseMessagingOpenedApp() {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Handling a notification click: ${message.messageId}");

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
}

void initFirebaseMessagingForegroundHandler() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
}

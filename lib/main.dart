import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/environment/environment_config.dart';
import 'package:expertapp/src/firebase/auth/auth_state_listener.dart';
import 'package:expertapp/src/firebase/cloud_messaging/message_handler.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/navigation/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:expertapp/src/firebase/auth/auth_state_listener.dart' as Auth;
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!EnvironmentConfig.getConfig().isProd()) {
    await connectToFirebaseEmulator();
  }

  AppLifecycle lifecycle = new AppLifecycle();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  AppRouter router = new AppRouter(lifecycle, navigatorKey);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  initFirebaseMessagingForegroundHandler(navigatorKey, lifecycle);
  initFirebaseMessagingOpenedApp();

  Stripe.publishableKey =
      "pk_test_51LLQIdAoQ8pfRhfFNyVrKysmtjgsXqW2zjx6IxcVpKjvq8iMqTTGRl8BCUnTYiIzq5HUkbnZ9dXtiibhdum3Ozfv00lOhg3RyX";


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CallServerModel>(
            create: (_) => CallServerModel()),
        ChangeNotifierProvider<AppLifecycle>.value(value: lifecycle),
      ],
      child: MyApp(lifecycle: lifecycle, router: router),
    ),
  );
}


class MyApp extends StatefulWidget {
  final AppLifecycle lifecycle;
  final AppRouter router;

  const MyApp({Key? key, required this.lifecycle, required this.router})
      : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Auth.AuthStateListener.listenForAuthChanges(onAuthStateCallback);
  }

  void onAuthStateCallback(FirebaseAuth.User? authStatusChange) async {
    widget.lifecycle.onAuthStatusChange(authStatusChange);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLifecycle>.value(
        value: widget.lifecycle,
        child: MaterialApp.router(
          title: "Expert App",
          routerConfig: widget.router.goRouter,
        ));
  }
}

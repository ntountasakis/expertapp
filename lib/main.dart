import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/environment/environment_config.dart';
import 'package:expertapp/src/firebase/auth/auth_providers.dart';
import 'package:expertapp/src/firebase/cloud_messaging/message_handler.dart';
import 'package:expertapp/src/firebase/dynamic_links/dynamic_link_handler.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/navigation/router.dart';
import 'package:expertapp/src/version/app_version.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:expertapp/src/firebase/auth/auth_state_listener.dart' as Auth;
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppVersion.initVersion();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!EnvironmentConfig.getConfig().isProd()) {
    await connectToFirebaseEmulator();
  }

  AppLifecycle lifecycle = new AppLifecycle();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  AppRouter router = new AppRouter(lifecycle, navigatorKey);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    criticalAlert: true,
    provisional: true,
  );

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseAuthProviders.configureProviders();

  Stripe.publishableKey =
      "pk_test_51LLQIdAoQ8pfRhfFNyVrKysmtjgsXqW2zjx6IxcVpKjvq8iMqTTGRl8BCUnTYiIzq5HUkbnZ9dXtiibhdum3Ozfv00lOhg3RyX";
  Stripe.merchantIdentifier = 'merchant.example.expertapp';

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

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  initFirebaseMessagingForegroundHandler(navigatorKey, lifecycle);
  initFirebaseMessagingOpenedApp(navigatorKey, lifecycle);

  await handleFirebaseDynamicLinkInitialLink(navigatorKey);
  listenForFirebaseDynamicLinks(navigatorKey);
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
          theme: FlexThemeData.light(
            scheme: FlexScheme.deepBlue,
          ),
        ));
  }
}

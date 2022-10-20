import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/environment/environment_config.dart';
import 'package:expertapp/src/firebase/cloud_messaging/message_handler.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/navigation/client_call_flow.dart';
import 'package:expertapp/src/screens/navigation/expert_profile_arguments.dart';
import 'package:expertapp/src/screens/navigation/home_flow.dart';
import 'package:expertapp/src/screens/navigation/root_page.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:expertapp/src/screens/navigation/sign_in_flow.dart';
import 'package:expertapp/src/screens/transaction/client/call_transaction_page_enum.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!EnvironmentConfig.getConfig().isProd()) {
    await connectToFirebaseEmulator();
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  initFirebaseMessagingForegroundHandler();
  initFirebaseMessagingOpenedApp();

  Stripe.publishableKey =
      "pk_test_51LLQIdAoQ8pfRhfFNyVrKysmtjgsXqW2zjx6IxcVpKjvq8iMqTTGRl8BCUnTYiIzq5HUkbnZ9dXtiibhdum3Ozfv00lOhg3RyX";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CallServerModel>(
            create: (_) => CallServerModel()),
        Provider<AppLifecycle>(create: (_) => AppLifecycle()),
      ],
      child: MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void onCallClientPageTransitionRequest(CallTransactionPageEnum request) {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: rootNavigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: Routes.SIGN_IN_START,
        onGenerateRoute: (settings) {
          late Widget page;
          if (settings.name == Routes.HOME) {
            page = RootPage();
          } else if (settings.name!.startsWith(Routes.EXPERT_LISTINGS)) {
            page = HomeFlow(settings.name!);
          } else if (settings.name!.startsWith(Routes.SIGN_IN_PREFIX)) {
            page = SignInFlow(Provider.of<AppLifecycle>(context, listen: false),
                settings.name!);
          } else if (settings.name!.startsWith(Routes.CLIENT_CALL_PREFIX)) {
            page = ClientCallFlow(
                settings.name!,
                settings.arguments as ExpertProfileArguments,
                Provider.of<AppLifecycle>(context, listen: false));
          } else {
            throw Exception("Unknown route: ${settings.name}");
          }

          return MaterialPageRoute(
            builder: (context) {
              return page;
            },
            settings: settings,
          );
        });
  }
}

import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/environment/environment_config.dart';
import 'package:expertapp/src/firebase/auth/auth_state_provider.dart';
import 'package:expertapp/src/firebase/cloud_messaging/message_handler.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/auth_gate_page.dart';
import 'package:expertapp/src/screens/expert_listings_page.dart';
import 'package:expertapp/src/screens/user_signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutterfire_ui/auth.dart';
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
    ChangeNotifierProvider(
      create: (context) => CallServerModel(),
      child: MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final appLifecycle = AppLifecycle();
  final authStateProvider = AuthStateProvider();
  var authState = AuthStateEnum.NEED_TO_SIGN_IN;
  DocumentWrapper<UserMetadata>? userMetadata;

  void authStateCallback(AuthStateEnum state) async {
    DocumentWrapper<UserMetadata>? potentialExistingUser = null;
    if (state == AuthStateEnum.SIGNED_IN) {
      potentialExistingUser =
          await UserMetadata.get(authStateProvider.currentUser!.uid);
    }
    userAndAuthState(authState, potentialExistingUser);
  }

  void userCreated(DocumentWrapper<UserMetadata> userCreatedMetadata) {
    appLifecycle.onUserLogin(userCreatedMetadata);
    userAndAuthState(authState, userCreatedMetadata);
  }

  void userAndAuthState(
      AuthStateEnum authState, DocumentWrapper<UserMetadata>? userMetadata) {
    setState(() {
      this.userMetadata = userMetadata;
      this.authState = authState;
    });
  }

  @override
  void initState() {
    super.initState();
    authStateProvider.listenForAuthChanges(authStateCallback);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: Navigator(
          pages: [
            if (userMetadata != null)
              MaterialPage(
                  key: ValueKey('ExpertListingsPage'),
                  child: ExpertListingsPage(userMetadata!))
            else if (authState == AuthStateEnum.NEED_TO_SIGN_IN)
              MaterialPage(
                  key: ValueKey('SignInScreen'),
                  child: SignInScreen(providerConfigs: [
                    EmailProviderConfiguration(),
                    GoogleProviderConfiguration(
                      clientId:
                          '111394228371-4slr6ceip09bqefipq2ikbvribtj93qj.apps.googleusercontent.com',
                    ),
                    FacebookProviderConfiguration(
                      clientId: '294313229392786',
                    )
                  ]))
            else
              MaterialPage(
                  key: ValueKey('UserCreationGatePage'),
                  child: UserSignupPage(appLifecycle,
                      authStateProvider.currentUser!, userCreated))
          ],
        ));
  }
}

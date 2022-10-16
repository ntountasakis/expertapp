import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/environment/environment_config.dart';
import 'package:expertapp/src/firebase/auth/auth_state_provider.dart';
import 'package:expertapp/src/firebase/cloud_messaging/message_handler.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pbgrpc.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/expert_listings_page.dart';
import 'package:expertapp/src/screens/expert_profile_page.dart';
import 'package:expertapp/src/screens/transaction/client/call_transaction_page_enum.dart';
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
  var authState = AuthStateEnum.START;
  DocumentWrapper<UserMetadata>? userMetadata;
  DocumentWrapper<UserMetadata>? selectedExpertUserMetadata;

  void authStateCallback(AuthStateEnum state) async {
    DocumentWrapper<UserMetadata>? potentialExistingUser =
        await UserMetadata.get(authStateProvider.currentUser!.uid);
    userAndAuthState(state, potentialExistingUser);
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

  void onExpertPreviewSelected(
      DocumentWrapper<UserMetadata> expertUserMetadata) {
    setState(() {
      selectedExpertUserMetadata = expertUserMetadata;
    });
  }

  void onCallClientPageTransitionRequest(CallTransactionPageEnum request) {
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
          primarySwatch: Colors.blue,
        ),
        home: Navigator(
          pages: [
            if (authState == AuthStateEnum.START)
              MaterialPage(
                key: ValueKey('START'),
                child: Scaffold(
                  appBar: AppBar(),
                  body: Container(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
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
            else if (userMetadata == null)
              MaterialPage(
                  key: ValueKey('UserCreationGatePage'),
                  child: UserSignupPage(appLifecycle,
                      authStateProvider.currentUser!, userCreated))
            else
              MaterialPage(
                  key: ValueKey('ExpertListingsPage'),
                  child: ExpertListingsPage(
                      userMetadata!, onExpertPreviewSelected)),
            if (selectedExpertUserMetadata != null && userMetadata != null)
              MaterialPage(
                  key: ValueKey('ExpertProfilePage' +
                      selectedExpertUserMetadata!.documentId),
                  name: 'ExpertProfilePage',
                  child: ExpertProfilePage(
                      userMetadata!.documentId, selectedExpertUserMetadata!,
                      onCallClientPageTransitionRequest))
          ],
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }
            if (route.settings.name == 'ExpertProfilePage') {
              setState(() {
                selectedExpertUserMetadata = null;
              });
            }
            return true;
          },
        ));
  }
}

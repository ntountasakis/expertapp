import 'package:expertapp/firebase_options.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/emulator/configure_emulator.dart';
import 'package:expertapp/src/generated/protos/call_transaction.pb.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_summary.dart';
import 'package:expertapp/src/screens/transaction/expert/call_expert_summary.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';

class TestAppRouter {
  final AppLifecycle lifecycle;
  final GlobalKey<NavigatorState> navigatorKey;
  final String startRoute;

  GoRouter get goRouter => _goRouter;

  TestAppRouter(this.lifecycle, this.navigatorKey, this.startRoute);

  late final GoRouter _goRouter = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: this.startRoute,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      return null;
    },
    refreshListenable: lifecycle,
    routes: <GoRoute>[
      GoRoute(
        name: Routes.EXPERT_CALL_SUMMARY_PAGE,
        path: Routes.EXPERT_CALL_SUMMARY_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return CallClientSummary(
            otherUserId: "mpKZBT949r8LM9wkzIvfl6GQQ2OQ",
          );
        },
      ),
      GoRoute(
        name: Routes.CLIENT_SUMMARY_PAGE,
        path: Routes.CLIENT_SUMMARY_PAGE,
        builder: (BuildContext context, GoRouterState state) {
          return CallExpertSummary();
        },
      ),
    ],
  );
}

Future<void> testHelper(String path) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await connectToFirebaseEmulator();

  final model = CallServerModel();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  AppLifecycle lifecycle = new AppLifecycle();
  TestAppRouter router = new TestAppRouter(lifecycle, navigatorKey, path);

  final summary = new ServerCallSummary();
  summary.lengthOfCallSec = 100;
  summary.costOfCallCents = 1750;
  summary.paymentProcessorFeeCents = 250;
  summary.platformFeeCents = 550;
  summary.earnedTotalCents = summary.costOfCallCents -
      summary.paymentProcessorFeeCents -
      summary.platformFeeCents;
  model.onServerCallSummary(summary);

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider<CallServerModel>(create: (_) => model),
        ],
        child: MaterialApp.router(
          title: "test",
          routerConfig: router.goRouter,
        )),
  );
}

void main() async {
  final path = Routes.CLIENT_SUMMARY_PAGE;
  // final path = Routes.CLIENT_CALL_SUMMARY_PAGE;
  await testHelper(path);
}
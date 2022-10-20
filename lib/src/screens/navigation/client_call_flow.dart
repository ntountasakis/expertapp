import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/navigation/expert_profile_arguments.dart';
import 'package:expertapp/src/screens/navigation/root_page.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:expertapp/src/screens/transaction/client/call_begin_client_payment_page.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_main.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_summary.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_terminate_payment_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientCallFlow extends StatefulWidget {
  final String initRoute;
  final ExpertProfileArguments args;
  final AppLifecycle lifecycle;
  ClientCallFlow(this.initRoute, this.args, this.lifecycle);

  @override
  State<ClientCallFlow> createState() {
    CallServerManager callManager = new CallServerManager(
        currentUserId: lifecycle.theUserMetadata!.documentId,
        otherUserId: args.selectedExpert.documentId);

    return _ClientCallFlowState(callManager);
  }
}

class _ClientCallFlowState extends State<ClientCallFlow> {
  late CallServerManager callManager;

  _ClientCallFlowState(this.callManager);

  @override
  Widget build(BuildContext context) {
    Route _onGenerateRoute(RouteSettings settings) {
      late Widget page;
      AppLifecycle lifecycle =
          Provider.of<AppLifecycle>(context, listen: false);
      switch (settings.name) {
        case Routes.HOME:
          page = RootPage();
          break;
        case Routes.CLIENT_CALL_PAYMENT_BEGIN:
          page = CallBeginClientPaymentPage(
              currentUserId: lifecycle.theUserMetadata!.documentId,
              expertUserMetadata: widget.args.selectedExpert,
              callServerManager: callManager);
          break;
        case Routes.CLIENT_CALL_MAIN:
          page = CallClientMain(
              currentUserId: lifecycle.theUserMetadata!.documentId,
              connectedExpertMetadata: widget.args.selectedExpert,
              callServerManager: callManager);
          break;
        case Routes.CLIENT_CALL_PAYMENT_END:
          page = CallClientTerminatePaymentPage();
          break;
        case Routes.CLIENT_CALL_SUMMARY:
          page = CallClientSummary(callServerManager: callManager);
          break;
        default:
          throw Exception(
              "Unknown route in client call flow: ${settings.name}");
      }

      return MaterialPageRoute<dynamic>(
        builder: (context) {
          return page;
        },
        settings: settings,
      );
    }

    return Scaffold(
      body: Navigator(
        initialRoute: widget.initRoute,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}

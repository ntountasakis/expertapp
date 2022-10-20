import 'package:expertapp/src/screens/expert_listings_page.dart';
import 'package:expertapp/src/screens/expert_profile_page.dart';
import 'package:expertapp/src/screens/navigation/expert_call_preview_arguments.dart';
import 'package:expertapp/src/screens/navigation/expert_profile_arguments.dart';
import 'package:expertapp/src/screens/navigation/root_page.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:expertapp/src/screens/transaction/client/call_client_preview.dart';
import 'package:flutter/material.dart';

class HomeFlow extends StatefulWidget {
  final String initRoute;

  HomeFlow(this.initRoute);

  @override
  State<HomeFlow> createState() => _HomeFlowState();
}

class _HomeFlowState extends State<HomeFlow> {
  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;
    switch (settings.name) {
      case Routes.HOME:
        page = RootPage();
        break;
      case Routes.EXPERT_LISTINGS:
        page = ExpertListingsPage();
        break;
      case Routes.EXPERT_PROFILE_PAGE:
        final args = settings.arguments as ExpertProfileArguments;
        page = ExpertProfilePage(args.selectedExpert);
        break;
      case Routes.EXPERT_CALL_PREVIEW:
        final args = settings.arguments as ExpertCallPreviewArguments;
        page = CallClientPreview(args.selectedExpert, args.expertRate);
        break;
      default:
        throw Exception("Unknown route in home flow: ${settings.name}");
    }
    return MaterialPageRoute<dynamic>(
      builder: (context) {
        return page;
      },
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        initialRoute: widget.initRoute,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}

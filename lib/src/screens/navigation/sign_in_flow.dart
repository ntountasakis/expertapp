import 'dart:developer';

import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/firebase/auth/auth_state_listener.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:expertapp/src/screens/user_signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:expertapp/src/firebase/auth/auth_state_listener.dart' as Auth;
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class SignInFlow extends StatefulWidget {
  final AppLifecycle appLifecycle;
  final String initRoute;
  final GlobalKey<NavigatorState> rootNavigatorKey;
  SignInFlow(this.appLifecycle, this.initRoute, this.rootNavigatorKey);

  @override
  State<SignInFlow> createState() => _SignInFlowState();
}

class _SignInFlowState extends State<SignInFlow> {
  final _signInFlowNavigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    Auth.AuthStateListener.listenForAuthChanges(onAuthStateCallback);
  }

  void onAuthStateCallback(
      AuthStateEnum state, FirebaseAuth.User? currentUser) async {
    DocumentWrapper<UserMetadata>? potentialExistingUser = null;
    widget.appLifecycle.onAuthStatusChange(currentUser);
    if (state == AuthStateEnum.NEED_TO_SIGN_IN) {
      _signInFlowNavigatorKey.currentState!.pushNamed(Routes.signInAuthPage);
    } else {
      assert(state == AuthStateEnum.SIGNED_IN);
      potentialExistingUser = await UserMetadata.get(currentUser!.uid);
      if (potentialExistingUser != null) {
        widget.appLifecycle.onUserLogin(potentialExistingUser);
        // Navigator.of(context).pop();
        widget.rootNavigatorKey.currentState!.popAndPushNamed(Routes.HOME);
      } else {
        _signInFlowNavigatorKey.currentState!.popAndPushNamed(Routes.signInUserCreatePage);
      }
    }
  }

  void onUserCreated(DocumentWrapper<UserMetadata> userCreatedMetadata) {
    widget.appLifecycle.onUserLogin(userCreatedMetadata);
    widget.rootNavigatorKey.currentState!.popAndPushNamed(Routes.HOME);
  }

  Route _onGenerateRoute(RouteSettings settings) {
    late Widget page;
    log("Signin flow name: ${settings.name}");
    switch (settings.name) {
      case Routes.signInAuthPage:
        page = SignInScreen(providerConfigs: [
          EmailProviderConfiguration(),
          GoogleProviderConfiguration(
            clientId:
                '111394228371-4slr6ceip09bqefipq2ikbvribtj93qj.apps.googleusercontent.com',
          ),
          FacebookProviderConfiguration(
            clientId: '294313229392786',
          )
        ]);
        break;
      case Routes.signInUserCreatePage:
        page = UserSignupPage(
            widget.appLifecycle.theAuthenticatedUser!, onUserCreated);
        break;
      case Routes.signInStartPage:
        page = Scaffold(
          body: Container(
            child: Text("Sign in start"),
          ),
        );
        break;
      default:
        throw new Exception("Unknown signin route: ${settings.name}");
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
        key: _signInFlowNavigatorKey,
        initialRoute: widget.initRoute,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}

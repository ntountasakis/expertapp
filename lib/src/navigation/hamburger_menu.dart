import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HamburgerMenu extends StatelessWidget {
  final bool isSignedIn;
  final String? currentUserId;

  const HamburgerMenu({required this.isSignedIn, this.currentUserId});

  ListTile pastChatsTile(BuildContext context) {
    return ListTile(
        title: Text("Past Chats"),
        onTap: () {
          context.pushNamed(Routes.UV_PAST_CHATS);
        });
  }

  ListTile profileTile(BuildContext context) {
    return ListTile(
        title: Text("My Profile"),
        onTap: () {
          context.pushNamed(Routes.EV_PROFILE_EDIT_PAGE,
              params: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "false"});
        });
  }

  ListTile pastCallsWithExpertsTile(BuildContext context) {
    return ListTile(
        title: Text("Past Calls with Experts"),
        onTap: () {
          context.pushNamed(Routes.UV_COMPLETED_CALLS_PAGE);
        });
  }

  ListTile pastCallsWithClientsTile(BuildContext context) {
    return ListTile(
        title: Text("Past Calls with Clients"),
        onTap: () {
          context.pushNamed(Routes.EV_COMPLETED_CALLS_PAGE);
        });
  }

  ListTile updateCallPricesTile(BuildContext context) {
    return ListTile(
        title: Text("Update Call Prices"),
        onTap: () {
          context.pushNamed(Routes.EV_UPDATE_RATE_PAGE,
              params: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "false"});
        });
  }

  ListTile updateCallAvailabilityTile(BuildContext context) {
    return ListTile(
        title: Text("Update Call Availability Times"),
        onTap: () {
          context.pushNamed(Routes.EV_UPDATE_AVAILABILITY_PAGE,
              params: {Routes.FROM_EXPERT_SIGNUP_FLOW_PARAM: "false"});
        });
  }

  ListTile stripeEarningsDashboard(BuildContext context) {
    return ListTile(
        title: Text("Stripe Earnings Dashboard"),
        onTap: () {
          context.pushNamed(Routes.EV_STRIPE_EARNINGS_DASHBOARD);
        });
  }

  ListTile stripePaymentMethodsDashboard(BuildContext context) {
    return ListTile(
        title: Text("Manage Your Payment Methods"),
        onTap: () {
          context.pushNamed(Routes.UV_STRIPE_PAYMENT_METHODS_DASHBOARD);
        });
  }

  ListTile becomeAnExpertTile(BuildContext context) {
    return ListTile(
        title: Text("Become an Expert!"),
        onTap: () {
          context.pushNamed(Routes.EV_CONNECTED_ACCOUNT_SIGNUP_PAGE);
        });
  }

  ListTile finishSignUpExpertTile(BuildContext context) {
    return ListTile(
        title: Text("Complete Expert Signup"),
        onTap: () {
          context.pushNamed(Routes.EV_CONNECTED_ACCOUNT_SIGNUP_PAGE);
        });
  }

  ListTile signOutTile(BuildContext context) {
    return ListTile(
        title: Text("Sign Out"),
        onTap: () async {
          await FirebaseAuth.FirebaseAuth.instance.signOut();
        });
  }

  ListTile createNoUserAccountSignInTile(BuildContext context) {
    final text =
        isSignedIn ? "Complete Account Signup" : "Create Account / Sign In";
    return ListTile(
        title: Text(text),
        onTap: () async {
          context.pushReplacementNamed(Routes.SIGN_IN_PAGE);
        });
  }

  ListTile deleteAccountTile(BuildContext context) {
    const style = TextStyle(color: Colors.red);
    return ListTile(
        title: Text(
          "Delete Account",
          style: style,
        ),
        onTap: () async {
          context.pushNamed(Routes.DELETE_ACCOUNT_PAGE);
        });
  }

  Widget buildExpertMenu(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text("Main Menu"),
        ),
        profileTile(context),
        stripeEarningsDashboard(context),
        stripePaymentMethodsDashboard(context),
        pastCallsWithExpertsTile(context),
        pastCallsWithClientsTile(context),
        pastChatsTile(context),
        updateCallPricesTile(context),
        updateCallAvailabilityTile(context),
        signOutTile(context),
        deleteAccountTile(context),
      ]),
    );
  }

  Widget buildMidSignUpExpertMenu(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text("Main Menu"),
        ),
        finishSignUpExpertTile(context),
        signOutTile(context),
        deleteAccountTile(context),
      ]),
    );
  }

  Widget buildRegularUserMenu(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text("Main Menu"),
        ),
        becomeAnExpertTile(context),
        pastCallsWithExpertsTile(context),
        pastChatsTile(context),
        stripePaymentMethodsDashboard(context),
        signOutTile(context),
        deleteAccountTile(context),
      ]),
    );
  }

  Widget buildNoAccountMenu(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text("Main Menu"),
        ),
        createNoUserAccountSignInTile(context),
        isSignedIn ? deleteAccountTile(context) : Container(),
        isSignedIn ? signOutTile(context) : Container(),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) return buildNoAccountMenu(context);
    return FutureBuilder<List<DocumentWrapper<PublicExpertInfo>?>>(
      future: Future.wait([
        PublicExpertInfo.get(uid: currentUserId!, fromSignUpFlow: true),
        PublicExpertInfo.get(uid: currentUserId!, fromSignUpFlow: false),
      ]),
      builder: (BuildContext context,
          AsyncSnapshot<List<DocumentWrapper<PublicExpertInfo>?>> snapshot) {
        if (snapshot.hasData) {
          final stagingExpertInfo = snapshot.data![0];
          final publicExpertInfo = snapshot.data![1];
          if (stagingExpertInfo != null) {
            return buildMidSignUpExpertMenu(context);
          } else if (publicExpertInfo != null) {
            return buildExpertMenu(context);
          } else {
            return buildRegularUserMenu(context);
          }
        } else {
          return buildRegularUserMenu(context);
        }
      },
    );
  }
}

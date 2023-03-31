import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HamburgerMenu extends StatelessWidget {
  final String? currentUserId;

  const HamburgerMenu({required this.currentUserId});

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

  ListTile viewStripeEarningsDashboard(BuildContext context) {
    return ListTile(
        title: Text("View Stripe Earnings Dashboard"),
        onTap: () {
          context.pushNamed(Routes.EV_STRIPE_EARNINGS_DASHBOARD);
        });
  }

  ListTile becomeAnExpertTile(BuildContext context) {
    return ListTile(
        title: Text("Become an Expert!"),
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

  ListTile createAccountSignInTile(BuildContext context) {
    return ListTile(
        title: Text("Create Account / Sign in"),
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
        viewStripeEarningsDashboard(context),
        pastCallsWithExpertsTile(context),
        pastCallsWithClientsTile(context),
        updateCallPricesTile(context),
        updateCallAvailabilityTile(context),
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
        createAccountSignInTile(context),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) return buildNoAccountMenu(context);
    return FutureBuilder(
      future: PublicExpertInfo.get(currentUserId!),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
        return snapshot.hasData
            ? buildExpertMenu(context)
            : buildRegularUserMenu(context);
      },
    );
  }
}

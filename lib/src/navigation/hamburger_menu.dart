import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HamburgerMenu extends StatelessWidget {
  final String currentUserId;

  const HamburgerMenu({required this.currentUserId});

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
        pastCallsWithExpertsTile(context),
        pastCallsWithClientsTile(context),
        updateCallPricesTile(context),
        updateCallAvailabilityTile(context),
        signOutTile(context),
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
        signOutTile(context),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PublicExpertInfo.get(currentUserId),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
        return snapshot.hasData
            ? buildExpertMenu(context)
            : buildRegularUserMenu(context);
      },
    );
  }
}

import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HamburgerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text("Main Menu"),
          ),
          ListTile(
              title: Text("My Profile"),
              onTap: () {
                context.pushNamed(Routes.USER_PROFILE_PAGE);
              }),
          ListTile(
              title: Text("Past Calls with Experts"),
              onTap: () {
                context.pushNamed(Routes.USER_COMPLETED_CALLS);
              }),
          ListTile(
              title: Text("Past Calls with Clients"),
              onTap: () {
                context.pushNamed(Routes.CLIENT_COMPLETED_CALLS);
              }),
          ListTile(
              title: Text("Update Call Prices"),
              onTap: () {
                context.pushNamed(Routes.EXPERT_UPDATE_RATE_PAGE);
              }),
          ListTile(
              title: Text("Update Call Availability Times"),
              onTap: () {
                context.pushNamed(Routes.EXPERT_UPDATE_AVAILABILITY_PAGE);
              }),
          ListTile(
              title: Text("Become an Expert!"),
              onTap: () {
                context.pushNamed(Routes.EXPERT_CONNECTED_ACCOUNT_SIGNUP_PAGE);
              }),
          ListTile(
              title: Text("Sign Out"),
              onTap: () async {
                await FirebaseAuth.FirebaseAuth.instance.signOut();
              }),
        ],
      ),
    );
  }
}

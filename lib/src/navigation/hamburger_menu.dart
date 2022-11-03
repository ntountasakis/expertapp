import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/auth_gate_page.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class HamburgerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DocumentWrapper<UserMetadata> currentUserMetadata =
        Provider.of<AppLifecycle>(context, listen: false).userMetadata!;
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
              title: Text("Sign Out"),
              onTap: () async {
                await AuthGatePage.signOut();
              }),
        ],
      ),
    );
  }
}

import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/lifecycle/app_lifecycle.dart';
import 'package:expertapp/src/screens/auth_gate_page.dart';
import 'package:expertapp/src/screens/expert_listings_page.dart';
import 'package:expertapp/src/screens/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HamburgerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DocumentWrapper<UserMetadata> currentUserMetadata =
        Provider.of<AppLifecycle>(context, listen: false).theUserMetadata!;
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(
                        currentUserMetadata,
                      ),
                    ));
              }),
          ListTile(
              title: Text("Sign Out"),
              onTap: () async {
                // todo: sign out broken
                await AuthGatePage.signOut();
              }),
        ],
      ),
    );
  }
}

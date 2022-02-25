import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/expert_listings_page.dart';
import 'package:expertapp/src/screens/user_profile_page.dart';
import 'package:flutter/material.dart';

class HamburgerMenu extends StatelessWidget {
  final DocumentWrapper<UserMetadata> _currentUserMetadata;

  const HamburgerMenu(this._currentUserMetadata);

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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(
                        _currentUserMetadata,
                      ),
                    ));
              }),
          ListTile(
              title: Text("Expert Listings"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpertListingsPage(
                        _currentUserMetadata,
                      ),
                    ));
              }),
        ],
      ),
    );
  }
}

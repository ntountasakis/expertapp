import 'package:expertapp/src/database/database_paths.dart';
import 'package:expertapp/src/database/user_loader.dart';
import 'package:expertapp/src/expert_listing_preview.dart';
import 'package:flutter/material.dart';

import 'database/models/user_id.dart';

class ExpertListings extends StatefulWidget {
  @override
  _ExpertListingsState createState() => _ExpertListingsState();
}

class _ExpertListingsState extends State<ExpertListings> {
  final _userStream = UserLoader(DatabasePaths.EXPERT_USERS);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _userStream.getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final myUsers = snapshot.data as List<UserId>;
            return ListView.builder(
                itemCount: myUsers.length,
                itemBuilder: (context, index) {
                  return ExpertListingPreview(myUsers[index]);
                });
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

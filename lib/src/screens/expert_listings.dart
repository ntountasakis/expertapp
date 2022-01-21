import 'package:expertapp/src/expert_listing_preview.dart';
import 'package:flutter/material.dart';

import '../firebase/database/database_paths.dart';
import '../firebase/database/models/user_id.dart';
import '../firebase/database/user_loader.dart';

class ExpertListings extends StatefulWidget {
  @override
  _ExpertListingsState createState() => _ExpertListingsState();
}

class _ExpertListingsState extends State<ExpertListings> {
  final _userStream = UserLoader(DatabasePaths.EXPERT_USERS);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Expert Listings')),
        body: Container(
            child: StreamBuilder(
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
                })));
  }
}

import 'package:expertapp/src/expert_listing_preview.dart';
import 'package:expertapp/src/firebase/database/models/user_information.dart';
import 'package:expertapp/src/screens/auth_gate_page.dart';
import 'package:flutter/material.dart';

class ExpertListingsPage extends StatefulWidget {
  final UserInformation _currentUser;

  const ExpertListingsPage(this._currentUser);

  @override
  _ExpertListingsPageState createState() => _ExpertListingsPageState();
}

class _ExpertListingsPageState extends State<ExpertListingsPage> {
  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 8));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: ElevatedButton(
              style: style,
              onPressed: () async {
                await AuthGatePage.signOut();
              },
              child: const Text('Sign Out'),
            ),
            title: Text('Expert Listings')),
        body: Container(
            child: StreamBuilder(
                stream: UserInformation.getStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final myUsers = snapshot.data as List<UserInformation>;
                    return ListView.builder(
                        itemCount: myUsers.length,
                        itemBuilder: (context, index) {
                          return ExpertListingPreview(widget._currentUser, myUsers[index]);
                        });
                  } else {
                    return CircularProgressIndicator();
                  }
                })));
  }
}

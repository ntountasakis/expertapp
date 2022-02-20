import 'package:expertapp/src/expert_listing_preview.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_information.dart';
import 'package:expertapp/src/screens/auth_gate_page.dart';
import 'package:flutter/material.dart';

class ExpertListingsPage extends StatefulWidget {
  final DocumentWrapper<UserInformation> _currentUser;

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
        body: StreamBuilder(
            stream: UserInformation.getStream(),
            builder: (BuildContext context,
                AsyncSnapshot<Iterable<DocumentWrapper<UserInformation>>>
                    snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ExpertListingPreview(
                          widget._currentUser, snapshot.data!.elementAt(index));
                    });
              } else {
                return Text("Loading.....");
              }
            }));
  }
}

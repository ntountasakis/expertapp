import 'package:expertapp/src/expert_listing_preview.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/navigation/hamburger_menu.dart';
import 'package:flutter/material.dart';

class ExpertListingsPage extends StatefulWidget {
  final DocumentWrapper<UserMetadata> _currentUserMetadata;

  const ExpertListingsPage(this._currentUserMetadata);

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
          title: Text('Expert Listings'),
        ),
        drawer: HamburgerMenu(widget._currentUserMetadata),
        body: StreamBuilder(
            stream: UserMetadata.getStream(),
            builder: (BuildContext context,
                AsyncSnapshot<Iterable<DocumentWrapper<UserMetadata>>>
                    snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ExpertListingPreview(
                        widget._currentUserMetadata.documentId,
                        snapshot.data!.elementAt(index),
                      );
                    });
              } else {
                return Text("Loading.....");
              }
            }));
  }
}

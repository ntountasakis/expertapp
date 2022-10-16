import 'package:expertapp/src/expert_listing_preview.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/navigation/hamburger_menu.dart';
import 'package:flutter/material.dart';

class ExpertListingsPage extends StatelessWidget {
  static final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 8));
  final DocumentWrapper<UserMetadata> _currentUserMetadata;
  final Function(DocumentWrapper<UserMetadata>) _onExpertSelected;

  const ExpertListingsPage(this._currentUserMetadata, this._onExpertSelected);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Expert Listings'),
        ),
        drawer: HamburgerMenu(_currentUserMetadata, _onExpertSelected),
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
                        snapshot.data!.elementAt(index),
                        _onExpertSelected,
                      );
                    });
              } else {
                return Text("Loading.....");
              }
            }));
  }
}

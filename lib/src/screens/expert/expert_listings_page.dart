import 'package:expertapp/src/profile/expert/expert_listing_preview.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/hamburger_menu.dart';
import 'package:flutter/material.dart';

class ExpertListingsPage extends StatelessWidget {
  static final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 8));

  const ExpertListingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Expert Listings'),
        ),
        drawer: HamburgerMenu(),
        body: StreamBuilder(
            stream: PublicExpertInfo.getStream(),
            builder: (BuildContext context,
                AsyncSnapshot<Iterable<DocumentWrapper<PublicExpertInfo>>>
                    snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ExpertListingPreview(
                        snapshot.data!.elementAt(index),
                      );
                    });
              } else {
                return Text("Loading.....");
              }
            }));
  }
}

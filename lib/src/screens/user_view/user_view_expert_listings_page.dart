import 'package:expertapp/src/profile/expert/expert_listing_card.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/hamburger_menu.dart';
import 'package:flutter/material.dart';

class UserViewExpertListingsPage extends StatelessWidget {
  final String currentUserId;

  static final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 8));

  const UserViewExpertListingsPage({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Expert Listings'),
        ),
        drawer: HamburgerMenu(
          currentUserId: currentUserId,
        ),
        body: StreamBuilder(
            stream: PublicExpertInfo.getStream(),
            builder: (BuildContext context,
                AsyncSnapshot<Iterable<DocumentWrapper<PublicExpertInfo>>>
                    snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ExpertListingCard(
                        snapshot.data!.elementAt(index),
                      );
                    });
              } else {
                return Text("Loading.....");
              }
            }));
  }
}

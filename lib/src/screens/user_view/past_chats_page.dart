import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/profile/profile_leading_tile.dart';
import 'package:expertapp/src/util/past_chat_card.dart';
import 'package:expertapp/src/util/tappable_card.dart';
import 'package:flutter/material.dart';

class PastChatsPage extends StatelessWidget {
  final uid;
  const PastChatsPage({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Past Chats')),
      body: FutureBuilder(
          future: getAllChatroomsForUser(),
          builder: (BuildContext context,
              AsyncSnapshot<Iterable<ChatroomPreview>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return FutureBuilder(
                    future: getDefaultProfilePicUrl(),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return buildTappableCard(
                            context: context,
                            leading: buildLeadingProfileTile(
                                context, "", snapshot.data!),
                            title: Text("No chats ... yet."),
                            subtitle: Text("View after your first chat"),
                            trailing: SizedBox(),
                            onTapCallback: null);
                      } else {
                        return SizedBox();
                      }
                    });
              }
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final preview = snapshot.data!.elementAt(index);
                    return PastChatCard(
                        key: Key(preview.otherUid),
                        currentUid: uid,
                        preview: preview);
                  });
            } else {
              return Text("Loading.....");
            }
          }),
    );
  }
}

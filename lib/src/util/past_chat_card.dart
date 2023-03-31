import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/expert/expert_listing_leading_tile.dart';
import 'package:expertapp/src/util/time_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PastChatCard extends StatelessWidget {
  final String currentUid;
  final ChatroomPreview preview;

  const PastChatCard(
      {Key? key, required this.currentUid, required this.preview})
      : super(key: key);

  Widget buildTitle() {
    return Text(
      preview.lastMessage,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget buildSubtitle(
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    final senderName = preview.lastMessageSenderUid == currentUid
        ? "You"
        : snapshot.hasData
            ? snapshot.data!.documentType.shortName()
            : "They";
    return Text(
        "$senderName sent on ${messageTimeAnnotation(preview.lastMessageMillisecondsSinceEpochUtc)}");
  }

  Widget buildLeading(BuildContext context,
      AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
    if (snapshot.hasData) {
      final publicExpertInfo = snapshot.data!;
      return buildLeadingExpertListingTile(
          context,
          publicExpertInfo.documentType.shortName(),
          publicExpertInfo.documentType.profilePicUrl);
    } else {
      return FutureBuilder(
          future: getDefaultProfilePicUrl(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final defaultUrl = snapshot.data as String;
              return buildLeadingExpertListingTile(
                  context, "Deleted User", defaultUrl);
            } else {
              return CircularProgressIndicator();
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PublicExpertInfo.get(preview.otherUid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
          return GestureDetector(
            onTap: () {
              context.pushNamed(Routes.UV_CALL_CHAT_PAGE, params: {
                Routes.EXPERT_ID_PARAM: preview.otherUid,
                Routes.IS_EDITABLE_PARAM: "false",
              });
            },
            child: Card(
              child: ListTile(
                dense: true,
                visualDensity: VisualDensity(
                    horizontal: VisualDensity.maximumDensity,
                    vertical: VisualDensity.maximumDensity),
                leading: buildLeading(context, snapshot),
                title: buildTitle(),
                subtitle: buildSubtitle(snapshot),
              ),
            ),
          );
        });
  }
}

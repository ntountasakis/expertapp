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

  Widget buildSubtitle(PublicExpertInfo publicExpertInfo) {
    final senderName = preview.lastMessageSenderUid == currentUid
        ? "You"
        : publicExpertInfo.firstName;
    return Text(
        "$senderName sent on ${messageTimeAnnotation(preview.lastMessageMillisecondsSinceEpochUtc)}");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PublicExpertInfo.get(preview.otherUid),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<PublicExpertInfo>?> snapshot) {
          if (snapshot.hasData) {
            final publicExpertInfo = snapshot.data!;
            return GestureDetector(
              onTap: () {
                context.pushNamed(Routes.UV_CALL_CHAT_PAGE, params: {
                  Routes.EXPERT_ID_PARAM: publicExpertInfo.documentId,
                  Routes.IS_EDITABLE_PARAM: "false",
                });
              },
              child: Card(
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity(
                      horizontal: VisualDensity.maximumDensity,
                      vertical: VisualDensity.maximumDensity),
                  leading:
                      buildLeadingExpertListingTile(context, publicExpertInfo),
                  title: buildTitle(),
                  subtitle: buildSubtitle(publicExpertInfo.documentType),
                ),
              ),
            );
          } else {
            return SizedBox();
          }
        });
  }
}

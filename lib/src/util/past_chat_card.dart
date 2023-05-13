import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/navigation/routes.dart';
import 'package:expertapp/src/profile/profile_leading_tile.dart';
import 'package:expertapp/src/util/tappable_card.dart';
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

  Widget buildSubtitle(DocumentWrapper<PublicUserInfo>? userInfo) {
    final senderName = preview.lastMessageSenderUid == currentUid
        ? "You"
        : userInfo != null
            ? userInfo.documentType.firstName
            : "They";
    return Text(
        "$senderName sent on ${messageTimeAnnotation(preview.lastMessageMillisecondsSinceEpochUtc)}");
  }

  Widget buildLeading(
      BuildContext context,
      DocumentWrapper<PublicExpertInfo>? expertInfo,
      DocumentWrapper<PublicUserInfo>? userInfo) {
    if (expertInfo != null) {
      return buildLeadingProfileTile(
          context: context,
          shortName: expertInfo.documentType.shortName(),
          profilePicUrl: expertInfo.documentType.profilePicUrl,
          showOnlineStatus: false,
          isOnline: false);
    } else {
      return FutureBuilder(
          future: getDefaultProfilePicUrl(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final defaultUrl = snapshot.data as String;
              final shortName = userInfo != null
                  ? userInfo.documentType.shortName()
                  : "Deleted User";
              return buildLeadingProfileTile(
                  context: context,
                  shortName: shortName,
                  profilePicUrl: defaultUrl,
                  showOnlineStatus: false,
                  isOnline: false);
            } else {
              return CircularProgressIndicator();
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          PublicExpertInfo.get(uid: preview.otherUid, fromSignUpFlow: false),
          PublicUserInfo.get(preview.otherUid)
        ]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final expertInfo = snapshot.data![0] != null
                ? snapshot.data![0] as DocumentWrapper<PublicExpertInfo>
                : null;
            final userInfo = snapshot.data![1] != null
                ? snapshot.data![1] as DocumentWrapper<PublicUserInfo>
                : null;

            return buildTappableCard(
                context: context,
                leading: buildLeading(context, expertInfo, userInfo),
                title: buildTitle(),
                subtitle: buildSubtitle(userInfo),
                trailing: SizedBox(),
                onTapCallback: (context) {
                  context.pushNamed(Routes.UV_CALL_CHAT_PAGE, pathParameters: {
                    Routes.EXPERT_ID_PARAM: preview.otherUid,
                    Routes.IS_EDITABLE_PARAM: "false",
                  });
                });
          }
          return SizedBox();
        });
  }
}

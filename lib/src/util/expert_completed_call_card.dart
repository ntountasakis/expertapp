import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:expertapp/src/profile/profile_leading_tile.dart';
import 'package:expertapp/src/util/completed_calls_util.dart';
import 'package:expertapp/src/util/tappable_card.dart';
import 'package:flutter/material.dart';

class ExpertCompletedCallCard extends StatelessWidget {
  final CallTransaction call;
  final String transactionId;
  const ExpertCompletedCallCard(this.call, this.transactionId, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String subtitle = 'Ended on ${CompletedCallsUtil.formatEndDate(call)}. '
        'Earned ${CompletedCallsUtil.formatCents(call.earnedTotalCents)} '
        'Length ${CompletedCallsUtil.formatCallLength(call)}';

    return FutureBuilder(
        future: Future.wait(
            [PublicUserInfo.get(call.callerUid), getDefaultProfilePicUrl()]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final publicUserInfo =
                snapshot.data![0] as DocumentWrapper<PublicUserInfo>?;
            final profilePicUrl = snapshot.data![1] as String;
            String shortName = publicUserInfo != null
                ? publicUserInfo.documentType.shortName()
                : 'Deleted User';
            String title = 'Completed call with ' + shortName;
            return buildTappableCard(
                context: context,
                leading: buildLeadingProfileTile(
                    context: context,
                    shortName: shortName,
                    profilePicUrl: profilePicUrl,
                    showOnlineStatus: false,
                    isOnline: false),
                title: Text(title),
                subtitle: Text(subtitle),
                trailing: SizedBox(),
                onTapCallback: (context) {
                  showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return CompletedCallsUtil.buildCallPopup(
                            call, transactionId);
                      });
                });
          } else {
            return SizedBox();
          }
        });
  }
}

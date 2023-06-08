import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/profile_leading_tile.dart';
import 'package:expertapp/src/util/completed_calls_util.dart';
import 'package:expertapp/src/util/tappable_card.dart';
import 'package:flutter/material.dart';

class UserCompletedCallCard extends StatelessWidget {
  final CallTransaction call;
  final String transactionId;
  const UserCompletedCallCard(this.call, this.transactionId, {Key? key})
      : super(key: key);

  void onTapCallback(BuildContext context) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CompletedCallsUtil.buildCallPopup(call, transactionId);
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait(
            [PublicExpertInfo.get(uid: call.calledUid, fromSignUpFlow: false)]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final expertMetadata =
                snapshot.data![0] as DocumentWrapper<PublicExpertInfo>?;

            String title =
                (call.lengthOfCallSec == 0 ? 'Canceled' : 'Completed') +
                    ' Call';
            if (expertMetadata != null) {
              title += ' with ' + expertMetadata.documentType.shortName();
            } else {
              title += ' with Deleted Guide';
            }

            String subtitle =
                'Ended on ${CompletedCallsUtil.formatEndDate(call)}. '
                'Paid ${CompletedCallsUtil.formatCents(call.costOfCallCents)} '
                'Length ${CompletedCallsUtil.formatCallLength(call)}';

            if (expertMetadata != null) {
              return buildTappableCard(
                  context: context,
                  leading: buildLeadingProfileTile(
                    context: context,
                    shortName: expertMetadata.documentType.shortName(),
                    profilePicUrl: expertMetadata.documentType.profilePicUrl,
                    showOnlineStatus: false,
                    isOnline: false,
                    isAvailable: false,
                  ),
                  title: Text(title),
                  subtitle: Text(subtitle),
                  trailing: SizedBox(),
                  onTapCallback: onTapCallback);
            } else {
              return FutureBuilder(
                  future: getDefaultProfilePicUrl(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return buildTappableCard(
                          context: context,
                          leading: buildLeadingProfileTile(
                            context: context,
                            shortName: "",
                            profilePicUrl: snapshot.data!,
                            showOnlineStatus: false,
                            isOnline: false,
                            isAvailable: false,
                          ),
                          title: Text(title),
                          subtitle: Text(subtitle),
                          trailing: SizedBox(),
                          onTapCallback: onTapCallback);
                    } else {
                      return SizedBox();
                    }
                  });
            }
          }
          return SizedBox();
        });
  }
}

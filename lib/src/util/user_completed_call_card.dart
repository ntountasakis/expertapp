import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/call_transaction.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/profile/profile_picture.dart';
import 'package:expertapp/src/util/completed_calls_util.dart';
import 'package:flutter/material.dart';

class UserCompletedCallCard extends StatelessWidget {
  final CallTransaction call;
  final String transactionId;
  const UserCompletedCallCard(this.call, this.transactionId, {Key? key})
      : super(key: key);

  static Widget buildCallCard(
      BuildContext context,
      String title,
      String subtitle,
      String? profilePicUrl,
      Function(BuildContext authState)? onTapCallback) {
    final card = Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: profilePicUrl != null
            ? SizedBox(width: 50, child: ProfilePicture(profilePicUrl))
            : null,
      ),
    );
    if (onTapCallback != null) {
      return GestureDetector(
        onTap: () {
          onTapCallback(context);
        },
        child: card,
      );
    }
    return card;
  }

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
        future: Future.wait([PublicExpertInfo.get(call.calledUid)]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            final expertMetadata =
                snapshot.data![0] as DocumentWrapper<PublicExpertInfo>?;

            String title = 'Completed Call';
            if (expertMetadata != null) {
              title += ' with ' + expertMetadata.documentType.shortName();
            } else {
              title += ' with Deleted Expert';
            }

            String subtitle =
                'Ended on ${CompletedCallsUtil.formatEndDate(call)}. '
                'Paid ${CompletedCallsUtil.formatCents(call.costOfCallCents)} '
                'Length ${CompletedCallsUtil.formatCallLength(call)}';

            if (expertMetadata != null) {
              return buildCallCard(context, title, subtitle,
                  expertMetadata.documentType.profilePicUrl, onTapCallback);
            } else {
              return FutureBuilder(
                  future: getDefaultProfilePicUrl(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return buildCallCard(context, title, subtitle,
                          snapshot.data!, onTapCallback);
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

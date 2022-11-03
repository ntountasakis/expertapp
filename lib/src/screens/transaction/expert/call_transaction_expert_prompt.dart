import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CallTransactionExpertPrompt extends StatelessWidget {
  final String transactionId;
  final String currentUserId;
  final String callerUserId;

  const CallTransactionExpertPrompt(
      {required this.transactionId,
      required this.currentUserId,
      required this.callerUserId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentWrapper<UserMetadata>?>(
        future: UserMetadata.get(callerUserId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<UserMetadata>?> snapshot) {
          if (snapshot.hasData) {
            final callerMetadata = snapshot.data;
            final callPrompt =
                'Call with ${callerMetadata!.documentType.firstName}';
            return Scaffold(
                appBar: UserPreviewAppbar(callerMetadata!),
                body: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(callPrompt),
                      ElevatedButton(
                        onPressed: () => {
                          context.goNamed(Routes.CLIENT_CALL_HOME, params: {
                            Routes.CALLER_UID_PARAM: callerUserId,
                            Routes.CALL_TRANSACTION_ID_PARAM: transactionId
                          })
                        },
                        child: Text("Join Call"),
                      ),
                    ],
                  ),
                ));
          }
          return Scaffold();
        });
  }
}

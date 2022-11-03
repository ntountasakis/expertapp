import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/widgets/call_server_counterparty_connection_state_view.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CallTransactionExpertMain extends StatefulWidget {
  final String callTransactionId;
  final String currentUserId;
  final String callerUserId;

  CallTransactionExpertMain(
      {required this.callTransactionId,
      required this.currentUserId,
      required this.callerUserId});

  @override
  State<CallTransactionExpertMain> createState() =>
      _CallTransactionExpertMainState(new CallServerManager(
          currentUserId: currentUserId, otherUserId: callerUserId));
}

class _CallTransactionExpertMainState extends State<CallTransactionExpertMain> {
  final CallServerManager callServerManager;

  _CallTransactionExpertMainState(this.callServerManager);

  Widget buildCallView(BuildContext context, CallServerModel model) {
    return Column(children: [
      Container(
        padding: EdgeInsets.all(8.0),
        child: callServerCounterpartyConnectionStateView(model),
      ),
      SizedBox(
        width: 200,
        height: 100,
      ),
      ElevatedButton(
        child: Text("Finish call"),
        onPressed: () {
          callServerManager.sendTerminateCallRequest(widget.callTransactionId);
          context.goNamed(Routes.HOME);
        },
      ),
      SizedBox(
        width: 200,
        height: 100,
      ),
      ElevatedButton(
        child: Text("Chat"),
        onPressed: () {
          context.pushNamed(Routes.CLIENT_CALL_CHAT_PAGE, params: {
            Routes.CALLER_UID_PARAM: widget.callerUserId,
            Routes.CALL_TRANSACTION_ID_PARAM: widget.callTransactionId,
          });
        },
      ),
      SizedBox(
        width: 200,
        height: 100,
      ),
      ElevatedButton(
          child: Text("Video"),
          onPressed: () {
            if (model.agoraCredentials == null) {
              log("No agora credentials");
            } else {
              context.pushNamed(Routes.CLIENT_CALL_VIDEO_PAGE, params: {
                Routes.CALLER_UID_PARAM: widget.callerUserId,
                Routes.CALL_TRANSACTION_ID_PARAM: widget.callTransactionId,
                Routes.AGORA_CHANNEL_NAME_PARAM:
                    model.agoraCredentials!.channelName,
                Routes.AGORA_TOKEN_PARAM: model.agoraCredentials!.token,
                Routes.AGORA_UID_PARAM: model.agoraCredentials!.uid.toString()
              });
            }
          }),
    ]);
  }

  Widget buildJoinCallButton(BuildContext context) {
    return ElevatedButton(
      child: const Text("Join call"),
      onPressed: () {
        callServerManager.joinCall(
            context: context, callTransactionId: widget.callTransactionId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentWrapper<UserMetadata>?>(
        future: UserMetadata.get(widget.callerUserId),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentWrapper<UserMetadata>?> snapshot) {
          if (snapshot.hasData) {
            final callerUserMetadata = snapshot.data;
            return Scaffold(
              appBar: UserPreviewAppbar(callerUserMetadata!),
              body: Consumer<CallServerModel>(
                builder: (context, model, child) {
                  if (model.callConnectionState ==
                      CallServerConnectionState.DISCONNECTED) {
                    return buildJoinCallButton(context);
                  }
                  return buildCallView(context, model);
                },
              ),
            );
          }
          return Scaffold(body: CircularProgressIndicator());
        });
  }
}

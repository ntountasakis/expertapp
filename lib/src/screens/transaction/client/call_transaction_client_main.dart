import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/widgets/call_server_connection_state_view.dart';
import 'package:expertapp/src/call_server/widgets/call_server_disconnect_button.dart';
import 'package:expertapp/src/call_server/widgets/call_server_editable_chat_button.dart';
import 'package:expertapp/src/call_server/widgets/call_server_video_call_button.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallTransactionClientMain extends StatelessWidget {
  final String currentUserId;
  final DocumentWrapper<UserMetadata> connectedExpertMetadata;
  final CallServerManager callServerManager;

  const CallTransactionClientMain(
      {required this.currentUserId,
      required this.connectedExpertMetadata,
      required this.callServerManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserPreviewAppbar(connectedExpertMetadata),
      body: Consumer<CallServerModel>(
        builder: (newContext, callstate, child) {
          return Column(children: [
            Container(
              padding: EdgeInsets.all(8.0),
              child: callServerConnectionStateView(callstate),
            ),
            SizedBox(
              width: 200,
              height: 100,
            ),
            Container(
              child: callServerDisconnectButton(newContext, callServerManager),
            ),
            SizedBox(
              width: 200,
              height: 100,
            ),
            Container(
              child: buildEditableChatButton(
                  context: newContext,
                  currentUserId: currentUserId,
                  calledUserMetadata: connectedExpertMetadata),
            ),
            SizedBox(
              width: 200,
              height: 100,
            ),
            Container(
              child: buildVideoCallButton(context: newContext, model: callstate),
            )
          ]);
        },
      ),
    );
  }
}

import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_connection_state.dart';
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

class CallTransactionExpertMain extends StatefulWidget {
  final String callTransactionId;
  final String currentUserId;
  final DocumentWrapper<UserMetadata> callerClientMetadata;

  CallTransactionExpertMain(
      {required this.callTransactionId,
      required this.currentUserId,
      required this.callerClientMetadata});

  @override
  State<CallTransactionExpertMain> createState() =>
      _CallTransactionExpertMainState(
          currentUserId: currentUserId,
          otherUserId: callerClientMetadata.documentId,
          callTransactionId: callTransactionId);
}

class _CallTransactionExpertMainState extends State<CallTransactionExpertMain> {
  final String callTransactionId;
  late CallServerManager _callManager;

  _CallTransactionExpertMainState(
      {required String currentUserId,
      required String otherUserId,
      required this.callTransactionId}) {
    _callManager = CallServerManager(
        currentUserId: currentUserId, otherUserId: otherUserId);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) => {
          _callManager.joinCall(
              context: context, callTransactionId: callTransactionId)
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserPreviewAppbar(widget.callerClientMetadata),
      body: Consumer<CallServerModel>(
        builder: (_, callstate, child) {
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
              child: callServerDisconnectButton(context, _callManager),
            ),
            SizedBox(
              width: 200,
              height: 100,
            ),
            Container(
              child: buildEditableChatButton(context: context, 
              currentUserId: widget.currentUserId, 
              calledUserMetadata: widget.callerClientMetadata)
            ),
            SizedBox(
              width: 200,
              height: 100,
            ),
            Container(
              child: buildVideoCallButton(context, widget.currentUserId),
            )
          ]);
        },
      ),
    );
  }
}

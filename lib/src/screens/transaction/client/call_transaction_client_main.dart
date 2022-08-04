import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/widgets/call_server_connection_state_view.dart';
import 'package:expertapp/src/call_server/widgets/call_server_disconnect_button.dart';
import 'package:expertapp/src/call_server/widgets/call_server_editable_chat_button.dart';
import 'package:expertapp/src/call_server/widgets/call_server_payment_prompt.dart';
import 'package:expertapp/src/call_server/widgets/call_server_video_call_button.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallTransactionClientMain extends StatefulWidget {
  final String currentUserId;
  final DocumentWrapper<UserMetadata> connectedExpertMetadata;

  CallTransactionClientMain(this.currentUserId, this.connectedExpertMetadata);

  @override
  State<CallTransactionClientMain> createState() =>
      _CallTransactionClientMainState(
          currentUserId: currentUserId,
          otherUserId: connectedExpertMetadata.documentId);
}

class _CallTransactionClientMainState extends State<CallTransactionClientMain> {
  late CallServerManager _callManager;

  _CallTransactionClientMainState(
      {required String currentUserId, required String otherUserId}) {
    _callManager = CallServerManager(
        currentUserId: currentUserId, otherUserId: otherUserId);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero)
        .then((_) => {_callManager.initiateCall(context)});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserPreviewAppbar(widget.connectedExpertMetadata),
      body: Consumer<CallServerModel>(
        builder: (_, callstate, child) {
          showPaymentPrompt(context: context, model: callstate);
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
              calledUserMetadata: widget.connectedExpertMetadata),
            ),
            SizedBox(
              width: 200,
              height: 100,
            ),
            Container(
              child: buildVideoCallButton(context: context, model: callstate),
            )
          ]);
        },
      ),
    );
  }
}

import 'dart:developer';

import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/call_server/widgets/call_server_connection_state_view.dart';
import 'package:expertapp/src/call_server/widgets/call_server_counterparty_connection_state_view.dart';
import 'package:expertapp/src/call_server/widgets/call_server_editable_chat_button.dart';
import 'package:expertapp/src/call_server/widgets/call_server_video_call_button.dart';
import 'package:expertapp/src/call_server/widgets/call_server_wrap_up_call_button.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'call_client_terminate_payment_page.dart';

class CallClientMain extends StatelessWidget {
  final String currentUserId;
  final DocumentWrapper<UserMetadata> connectedExpertMetadata;
  final CallServerManager callServerManager;

  const CallClientMain(
      {required this.currentUserId,
      required this.connectedExpertMetadata,
      required this.callServerManager});

  void navigateTerminatePaymentPage(BuildContext context) {
    callServerManager.sendTerminateCallRequest(
        Provider.of<CallServerModel>(context, listen: false).callTransactionId);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => callTerminatePaymentPage()));
  }

  Widget callTerminatePaymentPage() {
    return CallClientTerminatePaymentPage(
        connectedExpertMetadata: connectedExpertMetadata,
        callServerManager: callServerManager);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallServerModel>(
      builder: (context, model, child) {
        if (model.callCounterpartyConnectionState ==
            CallServerCounterpartyConnectionState.LEFT) {
          return callTerminatePaymentPage();
        }
        return Column(children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: callServerConnectionStateView(model),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: callServerCounterpartyConnectionStateView(model),
          ),
          SizedBox(
            width: 200,
            height: 100,
          ),
          Container(
            child: callServerWrapUpCallButton(
                context, navigateTerminatePaymentPage),
          ),
          SizedBox(
            width: 200,
            height: 100,
          ),
          Container(
            child: buildEditableChatButton(
                context: context,
                currentUserId: currentUserId,
                calledUserMetadata: connectedExpertMetadata),
          ),
          SizedBox(
            width: 200,
            height: 100,
          ),
          Container(
            child: buildVideoCallButton(context: context, model: model),
          )
        ]);
      },
    );
  }
}

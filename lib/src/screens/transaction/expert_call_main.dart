import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_manager.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpertCallMain extends StatefulWidget {
  final String currentUserId;
  final DocumentWrapper<UserMetadata> connectedUserMetadata;

  ExpertCallMain(this.currentUserId, this.connectedUserMetadata);

  @override
  State<ExpertCallMain> createState() => _ExpertCallMainState();
}

class _ExpertCallMainState extends State<ExpertCallMain> {
  final _callManager = CallServerManager();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) => {
          _callManager.connect(
            context: context,
            currentUserId: widget.currentUserId,
            calledUserId: widget.connectedUserMetadata.documentId,
          )
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserPreviewAppbar(widget.connectedUserMetadata),
      body: Consumer<CallServerModel>(
        builder: (_, callstate, child) {
          final stateStatus = callstate.callConnectionState;
          switch (stateStatus) {
            case CallServerConnectionState.DISCONNECTED:
              return Text("DISCONNECTED");
            case CallServerConnectionState.CONNECTING:
              return Text("CONNECTING");
            case CallServerConnectionState.CONNECTED:
              return Text("CONNECTED");
            case CallServerConnectionState.ERRORED:
              return Text("Call request denied. Error: ${callstate.errorMsg}");
          }
        },
      ),
    );
  }
}

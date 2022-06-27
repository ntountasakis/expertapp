import 'package:expertapp/src/call_server/call_connection_state.dart';
import 'package:expertapp/src/call_server/call_manager.dart';
import 'package:expertapp/src/call_server/call_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/user_metadata.dart';
import 'package:expertapp/src/screens/appbars/user_preview_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpertCallMain extends StatefulWidget {
  final String currentUserId;
  final DocumentWrapper<UserMetadata> expertMetadata;

  ExpertCallMain(this.currentUserId, this.expertMetadata);

  @override
  State<ExpertCallMain> createState() => _ExpertCallMainState();
}

class _ExpertCallMainState extends State<ExpertCallMain> {
  final _callManager = CallManager();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) => {
          _callManager.call(
              context: context,
              currentUserId: widget.currentUserId,
              calledUserId: widget.expertMetadata.documentId)
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserPreviewAppbar(widget.expertMetadata),
      body: Consumer<CallModel>(
        builder: (_, callstate, child) {
          final stateStatus = callstate.callConnectionState;
          switch (stateStatus) {
            case CallConnectionState.DISCONNECTED:
              return Text("DISCONNECTED");
            case CallConnectionState.CONNECTING:
              return Text("CONNECTING");
            case CallConnectionState.CONNECTED:
              return Text("CONNECTED");
          }
        },
      ),
    );
  }
}

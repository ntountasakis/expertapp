import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/appbars/widgets/earnings_button.dart';
import 'package:expertapp/src/appbars/widgets/time_remaining.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpertInCallAppbar extends StatefulWidget with PreferredSizeWidget {
  final DocumentWrapper<PublicExpertInfo> userMetadata;
  final CallServerModel model;

  ExpertInCallAppbar(this.userMetadata, this.model);

  @override
  State<ExpertInCallAppbar> createState() => _ExpertInCallAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ExpertInCallAppbarState extends State<ExpertInCallAppbar> {
  TimeRemaining? callTimeRemaining = null;

  String buildTitle() {
    return "Call with " + widget.userMetadata.documentType.firstName;
  }

  Widget buildInCallTimer(CallServerModel model) {
    if (callTimeRemaining == null) {
      callTimeRemaining = TimeRemaining(
          msRemaining: model.secMaxCallLength * 1000, onEnd: () => {});
    }
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(buildTitle()),
          ),
          SizedBox(
            width: 15,
          ),
          callTimeRemaining!,
          SizedBox(
            width: 15,
          ),
          earningsButton(context, widget.model),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallServerModel>(builder: (context, model, child) {
      if (model.callConnectionState == CallServerConnectionState.UNCONNECTED ||
          model.callCounterpartyConnectionState ==
              CallServerCounterpartyConnectionState.DISCONNECTED) {
        return SizedBox();
      }
      return buildInCallTimer(model);
    });
  }
}

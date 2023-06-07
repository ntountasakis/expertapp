import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/appbars/widgets/earnings_button.dart';
import 'package:expertapp/src/appbars/widgets/time_remaining.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ExpertInCallAppbar extends StatefulWidget implements PreferredSizeWidget {
  final DocumentWrapper<PublicUserInfo> userMetadata;
  final CallServerModel model;

  ExpertInCallAppbar(this.userMetadata, this.model);

  @override
  State<ExpertInCallAppbar> createState() => _ExpertInCallAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ExpertInCallAppbarState extends State<ExpertInCallAppbar> {
  TimeRemaining? callTimeRemaining = null;

  Widget buildTitle(CallServerModel model) {
    final prefix = model.callCounterpartyConnectionState ==
            CallServerCounterpartyConnectionState.READY_TO_START_CALL
        ? "Call with "
        : "Connecting you to ";
    final text = prefix + widget.userMetadata.documentType.firstName;
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(
        text,
      ),
    );
  }

  Widget buildInCallAppBar(CallServerModel model) {
    if (callTimeRemaining == null && model.callReady()) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          callTimeRemaining = TimeRemaining(
              msRemaining: model.callRemainingSeconds() * 1000,
              onEnd: () => {});
        });
      });
    }
    return AppBar(
      title: Row(
        children: [
          buildTitle(model),
          SizedBox(
            width: 15,
          ),
          callTimeRemaining != null ? callTimeRemaining! : Container(),
          Spacer(),
          callTimeRemaining != null
              ? earningsButton(context, widget.model)
              : Container(),
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
      return buildInCallAppBar(model);
    });
  }
}

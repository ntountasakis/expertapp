import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/appbars/widgets/cost_button.dart';
import 'package:expertapp/src/appbars/widgets/time_remaining.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ClientInCallAppbar extends StatefulWidget implements PreferredSizeWidget {
  final DocumentWrapper<PublicExpertInfo> userMetadata;
  final bool allowBackButton;

  ClientInCallAppbar(this.userMetadata, this.allowBackButton);

  @override
  State<ClientInCallAppbar> createState() => _ClientInCallAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ClientInCallAppbarState extends State<ClientInCallAppbar> {
  TimeRemaining? timeRemainingCalledToJoin;
  TimeRemaining? timeRemainingMainCall;

  Widget buildWaitingForCallToJoinTitle() {
    final text = "Waiting for " +
        widget.userMetadata.documentType.firstName +
        " to join ";
    return buildTitle(text);
  }

  Widget buildMainCallTitle(CallServerModel model) {
    final prefix = model.callCounterpartyConnectionState ==
            CallServerCounterpartyConnectionState.READY_TO_START_CALL
        ? "Call with "
        : "Connecting you to ";
    final text = prefix + widget.userMetadata.documentType.firstName;
    return buildTitle(text);
  }

  Widget buildTitle(String titleText) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(
        titleText,
      ),
    );
  }

  Widget buildWaitingForCallToJoin(CallServerModel model) {
    if (timeRemainingCalledToJoin == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          timeRemainingCalledToJoin = new TimeRemaining(
            msRemaining: msRemainingToJoin(model.callJoinTimeExpiryUtcMs),
            onEnd: () => {},
          );
        });
      });
      return AppBar(
        automaticallyImplyLeading: widget.allowBackButton,
      );
    }
    return AppBar(
      automaticallyImplyLeading: widget.allowBackButton,
      title: Row(
        children: [
          buildWaitingForCallToJoinTitle(),
          Spacer(),
          timeRemainingCalledToJoin!,
        ],
      ),
    );
  }

  Widget buildInCallAppBar(CallServerModel model) {
    if (timeRemainingMainCall == null && model.callReady()) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          timeRemainingCalledToJoin = null;
          timeRemainingMainCall = new TimeRemaining(
              msRemaining: model.callRemainingSeconds() * 1000,
              onEnd: (() => {}));
        });
      });
    }
    return AppBar(
      automaticallyImplyLeading: widget.allowBackButton,
      title: Row(
        children: [
          buildMainCallTitle(model),
          SizedBox(
            width: 15,
          ),
          timeRemainingMainCall != null ? timeRemainingMainCall! : Container(),
          Spacer(),
          timeRemainingMainCall != null
              ? costButton(context, model)
              : Container(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallServerModel>(builder: (context, model, child) {
      if (model.callConnectionState == CallServerConnectionState.UNCONNECTED) {
        return AppBar(
          automaticallyImplyLeading: widget.allowBackButton,
          title: buildTitle(
            "Connecting to server...",
          ),
        );
      }
      if (model.callJoinTimeExpiryUtcMs == 0) {
        return AppBar(
          automaticallyImplyLeading: widget.allowBackButton,
          title: buildTitle(
            "Awaiting payment pre-authorization",
          ),
        );
      }
      if (model.callCounterpartyConnectionState ==
          CallServerCounterpartyConnectionState.DISCONNECTED) {
        return buildWaitingForCallToJoin(model);
      }
      return buildInCallAppBar(model);
    });
  }
}

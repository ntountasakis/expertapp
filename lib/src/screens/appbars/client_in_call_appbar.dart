import 'package:expertapp/src/call_server/call_server_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/firebase/firestore/document_models/document_wrapper.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/screens/appbars/widgets/cost_button.dart';
import 'package:expertapp/src/screens/appbars/widgets/time_remaining.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class ClientInCallAppbar extends StatefulWidget with PreferredSizeWidget {
  final DocumentWrapper<PublicExpertInfo> userMetadata;

  ClientInCallAppbar(this.userMetadata);

  @override
  State<ClientInCallAppbar> createState() => _ClientInCallAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ClientInCallAppbarState extends State<ClientInCallAppbar> {
  TimeRemaining? timeRemainingCalledToJoin;
  TimeRemaining? timeRemainingMainCall;
  final textStylePreCall = TextStyle(fontSize: 16);
  final textStyleDuringCall = TextStyle(fontSize: 18);

  String buildWaitingForCallToJoinTitle() {
    return "Time left waiting for " +
        widget.userMetadata.documentType.firstName +
        " to join ";
  }

  String buildMainCallTitle() {
    return "Call with " + widget.userMetadata.documentType.firstName;
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
      return AppBar();
    }
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(
              buildWaitingForCallToJoinTitle(),
              style: textStylePreCall,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          timeRemainingCalledToJoin!,
        ],
      ),
    );
  }

  Widget buildInCallTimer(CallServerModel model) {
    if (timeRemainingMainCall == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          timeRemainingCalledToJoin = null;
          timeRemainingMainCall = new TimeRemaining(
              msRemaining: model.secMaxCallLength * 1000, onEnd: (() => {}));
        });
      });
      return AppBar();
    }
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(
              buildMainCallTitle(),
              style: textStyleDuringCall,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          timeRemainingMainCall!,
          SizedBox(
            width: 15,
          ),
          costButton(context, model),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallServerModel>(builder: (context, model, child) {
      if (model.callConnectionState == CallServerConnectionState.UNCONNECTED) {
        return AppBar(
          title: Text(
            "Connecting to server...",
            style: textStylePreCall,
          ),
        );
      }
      if (model.callJoinTimeExpiryUtcMs == 0) {
        return AppBar(
          title: Text(
            "Awaiting payment pre-authorization",
            style: textStylePreCall,
          ),
        );
      }
      if (model.callCounterpartyConnectionState ==
          CallServerCounterpartyConnectionState.DISCONNECTED) {
        return buildWaitingForCallToJoin(model);
      }
      return buildInCallTimer(model);
    });
  }
}

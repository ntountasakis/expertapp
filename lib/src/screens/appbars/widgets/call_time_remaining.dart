import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:provider/provider.dart';

class CallTimeRemaining extends StatefulWidget {
  @override
  State<CallTimeRemaining> createState() => _CallTimeRemainingState();
}

class _CallTimeRemainingState extends State<CallTimeRemaining> {
  Widget? countdownTimer;

  Widget callTimeRemaining(int maxCallLengthSec) {
    int endTime =
        DateTime.now().millisecondsSinceEpoch + (1000 * maxCallLengthSec);
    return CountdownTimer(
      endTime: endTime,
      endWidget: SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallServerModel>(builder: (context, model, child) {
      if (countdownTimer != null) {
        return countdownTimer!;
      }
      if (model.callCounterpartyConnectionState ==
          CallServerCounterpartyConnectionState.JOINED) {
        countdownTimer = callTimeRemaining(model.secMaxCallLength);
        return countdownTimer!;
      }
      return SizedBox();
    });
  }
}

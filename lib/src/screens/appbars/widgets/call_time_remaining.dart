import 'package:expertapp/src/call_server/call_server_counterparty_connection_state.dart';
import 'package:expertapp/src/call_server/call_server_model.dart';
import 'package:expertapp/src/screens/appbars/widgets/time_remaining.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallTimeRemaining extends StatefulWidget {
  @override
  State<CallTimeRemaining> createState() => _CallTimeRemainingState();
}

class _CallTimeRemainingState extends State<CallTimeRemaining> {
  Widget? countdownTimer;

  @override
  Widget build(BuildContext context) {
    return Consumer<CallServerModel>(builder: (context, model, child) {
      if (countdownTimer != null) {
        return countdownTimer!;
      }
      if (model.callCounterpartyConnectionState ==
          CallServerCounterpartyConnectionState.JOINED) {
        int msRemaining = (1000 * model.secMaxCallLength);
        countdownTimer =
            TimeRemaining(msRemaining: msRemaining, onEnd: (() => {}));
        return countdownTimer!;
      }
      return SizedBox();
    });
  }
}

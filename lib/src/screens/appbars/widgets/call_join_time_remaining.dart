import 'package:expertapp/src/screens/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:go_router/go_router.dart';

class CallJoinTimeRemaining extends StatefulWidget {
  final int callJoinExpirationTimeUtcMs;

  const CallJoinTimeRemaining({required this.callJoinExpirationTimeUtcMs});

  @override
  State<CallJoinTimeRemaining> createState() => _CallJoinTimeRemainingState();
}

class _CallJoinTimeRemainingState extends State<CallJoinTimeRemaining> {
  Widget? countdownTimer;
  late CountdownTimerController controller;
  int endTime = 0;

  @override
  void initState() {
    super.initState();
    int msRemaining = widget.callJoinExpirationTimeUtcMs -
        DateTime.now().toUtc().millisecondsSinceEpoch;
    endTime = DateTime.now().millisecondsSinceEpoch + msRemaining;
    controller = CountdownTimerController(
      endTime: endTime,
      onEnd: onEnd,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onEnd() {
    context.go(Routes.HOME);
  }

  Widget callJoinTimeRemaining() {
    return CountdownTimer(
      controller: controller,
      endTime: endTime,
      endWidget: SizedBox(),
      onEnd: onEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    return callJoinTimeRemaining();
  }
}

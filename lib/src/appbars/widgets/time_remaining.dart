import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';

int msRemainingToJoin(int callJoinExpirationTimeUtcMs) {
  int msSinceEpoch = new DateTime.now().millisecondsSinceEpoch;
  int msRemaining = callJoinExpirationTimeUtcMs - msSinceEpoch;
  if (msRemaining < 0) {
    msRemaining = 0;
  }
  return msRemaining;
}

class TimeRemaining extends StatefulWidget {
  final int msRemaining;
  final VoidCallback onEnd;

  const TimeRemaining({required this.msRemaining, required this.onEnd});

  @override
  State<TimeRemaining> createState() => _TimeRemainingState();
}

class _TimeRemainingState extends State<TimeRemaining> {
  late CountdownTimerController controller;
  late CountdownTimer countdownTimer;
  int endTime = 0;

  @override
  void initState() {
    super.initState();
    endTime = widget.msRemaining + DateTime.now().millisecondsSinceEpoch;
    controller = CountdownTimerController(
      endTime: endTime,
      onEnd: widget.onEnd,
    );
    countdownTimer = CountdownTimer(
      controller: controller,
      endTime: endTime,
      endWidget: SizedBox(),
      onEnd: widget.onEnd,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return countdownTimer;
  }
}

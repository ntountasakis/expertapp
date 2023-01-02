import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';

class TimeRemaining extends StatefulWidget {
  final int endTimeLocalMs;
  final VoidCallback onEnd;

  const TimeRemaining({required this.endTimeLocalMs, required this.onEnd});

  @override
  State<TimeRemaining> createState() => _TimeRemainingState();
}

class _TimeRemainingState extends State<TimeRemaining> {
  Widget? countdownTimer;
  late CountdownTimerController controller;

  @override
  void initState() {
    super.initState();
    controller = CountdownTimerController(
      endTime: widget.endTimeLocalMs,
      onEnd: widget.onEnd,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget callJoinTimeRemaining() {
    return CountdownTimer(
      controller: controller,
      endTime: widget.endTimeLocalMs,
      endWidget: SizedBox(),
      onEnd: widget.onEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    return callJoinTimeRemaining();
  }
}

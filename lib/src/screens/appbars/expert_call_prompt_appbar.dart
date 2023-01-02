import 'package:expertapp/src/screens/appbars/widgets/time_remaining.dart';
import 'package:flutter/material.dart';

int endTimeLocalMs(int callJoinExpirationTimeUtcMs) {
  int msRemaining = callJoinExpirationTimeUtcMs -
      DateTime.now().toUtc().millisecondsSinceEpoch;
  return DateTime.now().millisecondsSinceEpoch + msRemaining;
}

class ExpertCallPromptAppbar extends StatelessWidget with PreferredSizeWidget {
  final TimeRemaining joinTimeRemainingWidget;
  final int callJoinExpirationTimeUtcMs;
  final String callerName;
  final VoidCallback onCallJoinTimerExpires;

  ExpertCallPromptAppbar(this.callJoinExpirationTimeUtcMs, this.callerName,
      this.onCallJoinTimerExpires)
      : joinTimeRemainingWidget = TimeRemaining(
            endTimeLocalMs: endTimeLocalMs(callJoinExpirationTimeUtcMs),
            onEnd: onCallJoinTimerExpires);

  String buildTitle() {
    return "Call from $callerName. Time left to join: ";
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Text(
              buildTitle(),
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          joinTimeRemainingWidget,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

import 'package:expertapp/src/screens/appbars/widgets/time_remaining.dart';
import 'package:flutter/material.dart';

int msRemainingToJoin(int callJoinExpirationTimeUtcMs) {
  int msSinceEpoch = DateTime.now().toUtc().millisecondsSinceEpoch;
  int msRemaining = callJoinExpirationTimeUtcMs - msSinceEpoch;
  if (msRemaining < 0) {
    msRemaining = 0;
  }
  return msRemaining;
}

class ExpertCallPromptAppbar extends StatefulWidget with PreferredSizeWidget {
  final int callJoinExpirationTimeUtcMs;
  final String callerName;
  final VoidCallback onCallJoinTimerExpires;

  ExpertCallPromptAppbar(this.callJoinExpirationTimeUtcMs, this.callerName,
      this.onCallJoinTimerExpires);

  @override
  State<ExpertCallPromptAppbar> createState() =>
      _ExpertCallPromptAppbarState(TimeRemaining(
          msRemaining: msRemainingToJoin(callJoinExpirationTimeUtcMs),
          onEnd: onCallJoinTimerExpires));

  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ExpertCallPromptAppbarState extends State<ExpertCallPromptAppbar> {
  final TimeRemaining joinTimeRemainingWidget;

  _ExpertCallPromptAppbarState(this.joinTimeRemainingWidget);

  String buildTitle() {
    return "Call from ${widget.callerName}. Time left to join: ";
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

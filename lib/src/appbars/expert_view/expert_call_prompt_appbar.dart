import 'package:expertapp/src/appbars/widgets/time_remaining.dart';
import 'package:flutter/material.dart';

class ExpertCallPromptAppbar extends StatefulWidget implements PreferredSizeWidget {
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
}

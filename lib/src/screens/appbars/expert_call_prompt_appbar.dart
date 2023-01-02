import 'package:expertapp/src/screens/appbars/widgets/call_join_time_remaining.dart';
import 'package:flutter/material.dart';

class ExpertCallPromptAppbar extends StatelessWidget with PreferredSizeWidget {
  final CallJoinTimeRemaining joinTimeRemainingWidget;
  final int callJoinExpirationTimeUtcMs;
  final String callerName;

  ExpertCallPromptAppbar(this.callJoinExpirationTimeUtcMs, this.callerName)
      : joinTimeRemainingWidget = CallJoinTimeRemaining(
            callJoinExpirationTimeUtcMs: callJoinExpirationTimeUtcMs);

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

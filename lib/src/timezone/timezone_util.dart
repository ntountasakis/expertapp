import 'dart:core';
import 'dart:developer';

class TimezoneUtil {
  static int utcHour({required int hours}) {
    /* hours offset from utc will give the difference between the 
       local time and utc time. For example, for the Chicago time zone
       the offset is -6 hours. So 3pm chicago time is 9 pm utc time.
    */
    final hoursOffsetFromUtc = DateTime.now().timeZoneOffset.inHours;
    log("hoursOffsetFromUtc: $hoursOffsetFromUtc");
    log("final time: ${hours - hoursOffsetFromUtc}");

    return (hours - hoursOffsetFromUtc) % 24;
  }
}

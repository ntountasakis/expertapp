import 'dart:core';
import 'dart:developer';

class TimezoneUtil {
  static int utcHour({required int localHour}) {
    /* hours offset from utc will give the difference between the 
       local time and utc time. For example, for the Chicago time zone
       the offset is -6 hours. So 3pm chicago time is 9 pm utc time.
    */
    final hoursOffsetFromUtc = DateTime.now().timeZoneOffset.inHours;
    log("hoursOffsetFromUtc: $hoursOffsetFromUtc");
    log("final time: ${localHour - hoursOffsetFromUtc}");

    return (localHour - hoursOffsetFromUtc) % 24;
  }

  static int localHour({required int utcHour}) {
    final hoursOffsetFromUtc = DateTime.now().timeZoneOffset.inHours;
    log("hoursOffsetFromUtc: $hoursOffsetFromUtc");
    log("final time: ${utcHour - hoursOffsetFromUtc}");

    return (utcHour + hoursOffsetFromUtc) % 24;
  }
}

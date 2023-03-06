import 'package:expertapp/src/firebase/firestore/document_models/expert_availability.dart';

ExpertAvailability makeDefaultAvailability() {
  final dayAvailability = DayAvailability(
      isAvailable: false,
      startHourUtc: 0,
      endHourUtc: 0,
      startMinuteUtc: 0,
      endMinuteUtc: 0);
  final weekAvailability = ExpertAvailability(
      mondayAvailability: dayAvailability,
      tuesdayAvailability: dayAvailability,
      wednesdayAvailability: dayAvailability,
      thursdayAvailability: dayAvailability,
      fridayAvailability: dayAvailability,
      saturdayAvailability: dayAvailability,
      sundayAvailability: dayAvailability);
  return weekAvailability;
}

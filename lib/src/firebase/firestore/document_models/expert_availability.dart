class DayAvailability {
  final bool isAvailable;
  final int startHourUtc;
  final int startMinuteUtc;
  final int endHourUtc;
  final int endMinuteUtc;

  DayAvailability({
    required this.isAvailable,
    required this.startHourUtc,
    required this.startMinuteUtc,
    required this.endHourUtc,
    required this.endMinuteUtc,
  });

  DayAvailability.fromJson(Map<String, dynamic> json)
      : isAvailable = json['isAvailable'],
        startHourUtc = json['startHourUtc'],
        startMinuteUtc = json['startMinuteUtc'],
        endHourUtc = json['endHourUtc'],
        endMinuteUtc = json['endMinuteUtc'];

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'startHourUtc': startHourUtc,
      'startMinuteUtc': startMinuteUtc,
      'endHourUtc': endHourUtc,
      'endMinuteUtc': endMinuteUtc,
    };
  }
}

class ExpertAvailability {
  final DayAvailability mondayAvailability;
  final DayAvailability tuesdayAvailability;
  final DayAvailability wednesdayAvailability;
  final DayAvailability thursdayAvailability;
  final DayAvailability fridayAvailability;
  final DayAvailability saturdayAvailability;
  final DayAvailability sundayAvailability;

  ExpertAvailability({
    required this.mondayAvailability,
    required this.tuesdayAvailability,
    required this.wednesdayAvailability,
    required this.thursdayAvailability,
    required this.fridayAvailability,
    required this.saturdayAvailability,
    required this.sundayAvailability,
  });

  DayAvailability getDayAvailability(String day) {
    if (day == 'Monday')
      return mondayAvailability;
    else if (day == 'Tuesday')
      return tuesdayAvailability;
    else if (day == 'Wednesday')
      return wednesdayAvailability;
    else if (day == 'Thursday')
      return thursdayAvailability;
    else if (day == 'Friday')
      return fridayAvailability;
    else if (day == 'Saturday')
      return saturdayAvailability;
    else if (day == 'Sunday')
      return sundayAvailability;
    else
      throw new Exception('Invalid day: $day');
  }

  DayAvailability getCurrentDayAvailability() {
    final day = DateTime.now().weekday;
    if (day == DateTime.monday)
      return mondayAvailability;
    else if (day == DateTime.tuesday)
      return tuesdayAvailability;
    else if (day == DateTime.wednesday)
      return wednesdayAvailability;
    else if (day == DateTime.thursday)
      return thursdayAvailability;
    else if (day == DateTime.friday)
      return fridayAvailability;
    else if (day == DateTime.saturday)
      return saturdayAvailability;
    else if (day == DateTime.sunday)
      return sundayAvailability;
    else
      throw new Exception('Invalid day: $day');
  }

  Map<String, dynamic> toJson() {
    return {
      "mondayAvailability": mondayAvailability.toJson(),
      "tuesdayAvailability": tuesdayAvailability.toJson(),
      "wednesdayAvailability": wednesdayAvailability.toJson(),
      "thursdayAvailability": thursdayAvailability.toJson(),
      "fridayAvailability": fridayAvailability.toJson(),
      "saturdayAvailability": saturdayAvailability.toJson(),
      "sundayAvailability": sundayAvailability.toJson(),
    };
  }

  ExpertAvailability.fromJson(Map<String, dynamic> json)
      : mondayAvailability =
            DayAvailability.fromJson(json['mondayAvailability']),
        tuesdayAvailability =
            DayAvailability.fromJson(json['tuesdayAvailability']),
        wednesdayAvailability =
            DayAvailability.fromJson(json['wednesdayAvailability']),
        thursdayAvailability =
            DayAvailability.fromJson(json['thursdayAvailability']),
        fridayAvailability =
            DayAvailability.fromJson(json['fridayAvailability']),
        saturdayAvailability =
            DayAvailability.fromJson(json['saturdayAvailability']),
        sundayAvailability =
            DayAvailability.fromJson(json['sundayAvailability']);
}

import 'package:expertapp/src/firebase/firestore/document_models/expert_availability.dart';
import 'package:expertapp/src/timezone/timezone_util.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:flutter/material.dart';
import 'package:time_range/src/time_range.dart';

class ExpertAvailabilityUtil {
  static final List<String> DAYS = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  static Widget buildTimeSummary(
      {required BuildContext context,
      required ExpertAvailability availability,
      required String title}) {
    return Column(
      children: [
        Text(
          title,
          style: CallSummaryUtil.BOLD_STYLE,
        ),
        SizedBox(height: 20),
        for (String day in DAYS)
          _buildSummaryForDay(
              context: context,
              day: day,
              availability: availability.getDayAvailability(day)),
      ],
    );
  }

  static Widget _buildSummaryForDay(
      {required BuildContext context,
      required String day,
      required DayAvailability availability}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 20),
        Text(
          day,
          style: CallSummaryUtil.BOLD_STYLE,
        ),
        Spacer(),
        _buildAvailabilityText(context, availability),
        SizedBox(width: 20),
      ],
    );
  }

  static Text _buildAvailabilityText(
      BuildContext context, DayAvailability availability) {
    if (availability.isAvailable) {
      final start = TimeOfDay(
          hour: TimezoneUtil.localHour(utcHour: availability.startHourUtc),
          minute: availability.startMinuteUtc);
      final end = TimeOfDay(
          hour: TimezoneUtil.localHour(utcHour: availability.endHourUtc),
          minute: availability.endMinuteUtc);
      return Text(
        "${start.format(context)} - ${end.format(context)}",
        style: CallSummaryUtil.LIGHT_STYLE,
      );
    } else {
      return Text(
        "Not available",
        style: CallSummaryUtil.LIGHT_STYLE,
      );
    }
  }

  static ExpertAvailability convertToExpertAvailability(
      Map<String, TimeRangeResult?> selectedDays) {
    return ExpertAvailability(
      mondayAvailability: _convertToDayAvailability(selectedDays["Monday"]),
      tuesdayAvailability: _convertToDayAvailability(selectedDays["Tuesday"]),
      wednesdayAvailability:
          _convertToDayAvailability(selectedDays["Wednesday"]),
      thursdayAvailability: _convertToDayAvailability(selectedDays["Thursday"]),
      fridayAvailability: _convertToDayAvailability(selectedDays["Friday"]),
      saturdayAvailability: _convertToDayAvailability(selectedDays["Saturday"]),
      sundayAvailability: _convertToDayAvailability(selectedDays["Sunday"]),
    );
  }

  static _convertToDayAvailability(TimeRangeResult? selectedDay) {
    if (selectedDay == null) {
      return DayAvailability(
        isAvailable: false,
        startHourUtc: 0,
        startMinuteUtc: 0,
        endHourUtc: 0,
        endMinuteUtc: 0,
      );
    } else {
      return DayAvailability(
        isAvailable: true,
        startHourUtc: TimezoneUtil.utcHour(localHour: selectedDay.start.hour),
        startMinuteUtc: selectedDay.start.minute,
        endHourUtc: TimezoneUtil.utcHour(localHour: selectedDay.end.hour),
        endMinuteUtc: selectedDay.end.minute,
      );
    }
  }
}

import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/timezone/timezone_util.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:flutter/material.dart';
import 'package:day_picker/day_picker.dart';
import 'package:time_range/time_range.dart';

class ExpertAvailabilityPage extends StatefulWidget {
  @override
  State<ExpertAvailabilityPage> createState() => _ExpertAvailabilityPageState();
}

class _ExpertAvailabilityPageState extends State<ExpertAvailabilityPage> {
  final _selectedDays = new Map<String, TimeRangeResult?>();
  final _defaultInitialRange = TimeRangeResult(
    TimeOfDay(hour: 8, minute: 00),
    TimeOfDay(hour: 20, minute: 00),
  );

  String _mostRecentlySelectedDay = "";
  static const _daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  @override
  void initState() {
    super.initState();
    for (String day in _daysOfWeek) {
      _selectedDays[day] = null;
    }
  }

  String? getNewDayAdded(List<String> newDaysSelected) {
    for (String day in _selectedDays.keys) {
      if (newDaysSelected.contains(day) && _selectedDays[day] == null) {
        return day;
      }
    }
    return null;
  }

  String? getNewDayRemoved(List<String> newDaysSelected) {
    for (String day in _selectedDays.keys) {
      if (!newDaysSelected.contains(day) && _selectedDays[day] != null) {
        return day;
      }
    }
    return null;
  }

  void onDaysSelected(List<String> newDaysSelected) {
    int changedCount = 0;
    String changedDay = '';
    bool isSelected = false;
    for (String day in _selectedDays.keys) {
      bool wasSelected = _selectedDays[day] != null;
      isSelected = newDaysSelected.contains(day);
      if (isSelected != wasSelected) {
        changedCount++;
        changedDay = day;
      }
    }
    String? newDayAdded = getNewDayAdded(newDaysSelected);
    String? newDayRemoved = getNewDayRemoved(newDaysSelected);
    if (newDayAdded == null && newDayRemoved == null) {
      throw Exception('Expecting one day to be either added or removed');
    }
    if (newDayAdded != null && newDayRemoved != null) {
      throw Exception('Only one day can be either added or removed');
    }
    if (newDayAdded != null) {
      setState(() {
        _mostRecentlySelectedDay = newDayAdded;
        _selectedDays[newDayAdded] = _defaultInitialRange;
      });
    } else {
      setState(() {
        _mostRecentlySelectedDay = newDayRemoved!;
        _selectedDays[newDayRemoved] = null;
      });
    }
  }

  void onTimeRangeSelected(TimeRangeResult? range) {
    if (range == null) {
      return;
    }
    setState(() {
      _selectedDays[_mostRecentlySelectedDay] = range;
    });
  }

  Widget buildDayPicker() {
    List<DayInWeek> _days = [
      DayInWeek(_daysOfWeek[0]),
      DayInWeek(_daysOfWeek[1]),
      DayInWeek(_daysOfWeek[2]),
      DayInWeek(_daysOfWeek[3]),
      DayInWeek(_daysOfWeek[4]),
      DayInWeek(_daysOfWeek[5]),
      DayInWeek(_daysOfWeek[6]),
    ];
    return Row(
      children: [
        SizedBox(width: 10),
        Expanded(
          child: SelectWeekDays(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            days: _days,
            border: false,
            unSelectedDayTextColor: Colors.red[300],
            selectedDayTextColor: Colors.white,
            daysFillColor: Colors.green,
            boxDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                colors: [Colors.blue, Colors.blue],
                tileMode:
                    TileMode.repeated, // repeats the gradient over the canvas
              ),
            ),
            onSelect: onDaysSelected,
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget buildTimePicker() {
    if (_mostRecentlySelectedDay.isEmpty ||
        _selectedDays[_mostRecentlySelectedDay] == null) {
      return SizedBox();
    }
    return Column(
      children: [
        Text(
          "Select your availability for $_mostRecentlySelectedDay",
          style: CallSummaryUtil.BOLD_STYLE,
        ),
        SizedBox(height: 20),
        TimeRange(
          fromTitle: Text(
            'Allow calls starting at',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          toTitle: Text(
            'Do not allow calls starting at',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          titlePadding: 20,
          textStyle: CallSummaryUtil.LIGHT_STYLE,
          activeTextStyle: CallSummaryUtil.BOLD_STYLE,
          borderColor: Colors.black,
          backgroundColor: Colors.grey[200],
          activeBackgroundColor: Colors.green[400],
          firstTime: TimeOfDay(hour: 0, minute: 00),
          lastTime: TimeOfDay(hour: 24, minute: 00),
          initialRange: _selectedDays[_mostRecentlySelectedDay],
          timeStep: 15,
          timeBlock: 30,
          onRangeCompleted: onTimeRangeSelected,
        ),
      ],
    );
  }

  Widget buildSummaryForDay(String day) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 20),
        Text(
          day,
          style: CallSummaryUtil.BOLD_STYLE,
        ),
        Spacer(),
        Text(
          _selectedDays[day] == null
              ? "Not available"
              : "${_selectedDays[day]!.start.format(context)} - ${_selectedDays[day]!.end.format(context)}",
          style: CallSummaryUtil.LIGHT_STYLE,
        ),
        SizedBox(width: 20),
      ],
    );
  }

  Widget buildTimeSummary() {
    return Column(
      children: [
        Text(
          "Your availability",
          style: CallSummaryUtil.BOLD_STYLE,
        ),
        SizedBox(height: 20),
        for (String day in _selectedDays.keys) buildSummaryForDay(day),
      ],
    );
  }

  Widget buildSubmitAvailabilityButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[400],
        textStyle: const TextStyle(fontSize: 20),
      ),
      child: Text("Save updated availability"),
      onPressed: sendAvailability,
    );
  }

  DayAvailability buildAvailabilityForDay(String day) {
    final dayAvailability = _selectedDays[day];
    if (dayAvailability == null) {
      return DayAvailability(
        isAvailable: false,
        startHourUtc: 0,
        startMinuteUtc: 0,
        endHourUtc: 0,
        endMinuteUtc: 0,
      );
    }
    return DayAvailability(
        isAvailable: true,
        startHourUtc: TimezoneUtil.utcHour(hours: dayAvailability.start.hour),
        startMinuteUtc: dayAvailability.start.minute,
        endHourUtc: TimezoneUtil.utcHour(hours: dayAvailability.end.hour),
        endMinuteUtc: dayAvailability.end.minute);
  }

  Future<void> sendAvailability() async {
    final result = await updateExpertAvailability(
        mondayAvailability: buildAvailabilityForDay(_daysOfWeek[0]),
        tuesdayAvailability: buildAvailabilityForDay(_daysOfWeek[1]),
        wednesdayAvailability: buildAvailabilityForDay(_daysOfWeek[2]),
        thursdayAvailability: buildAvailabilityForDay(_daysOfWeek[3]),
        fridayAvailability: buildAvailabilityForDay(_daysOfWeek[4]),
        saturdayAvailability: buildAvailabilityForDay(_daysOfWeek[5]),
        sundayAvailability: buildAvailabilityForDay(_daysOfWeek[6]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Availability"),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          buildTimeSummary(),
          SizedBox(height: 20),
          buildSubmitAvailabilityButton(),
          SizedBox(height: 20),
          buildDayPicker(),
          SizedBox(height: 20),
          buildTimePicker(),
        ],
      ),
    );
  }
}

import 'package:expertapp/src/firebase/cloud_functions/callable_api.dart';
import 'package:expertapp/src/firebase/firestore/document_models/expert_availability.dart';
import 'package:expertapp/src/firebase/firestore/document_models/public_expert_info.dart';
import 'package:expertapp/src/timezone/timezone_util.dart';
import 'package:expertapp/src/util/call_summary_util.dart';
import 'package:expertapp/src/util/expert_availability_util.dart';
import 'package:flutter/material.dart';
import 'package:day_picker/day_picker.dart';
import 'package:flutter/scheduler.dart';
import 'package:time_range/time_range.dart';
import 'package:uuid/uuid.dart';

class ExpertAvailabilityUpdatePage extends StatefulWidget {
  final String uid;

  const ExpertAvailabilityUpdatePage({required this.uid});
  @override
  State<ExpertAvailabilityUpdatePage> createState() =>
      _ExpertAvailabilityUpdatePageState();
}

class _ExpertAvailabilityUpdatePageState
    extends State<ExpertAvailabilityUpdatePage> {
  bool _hasChanges = false;
  final _selectedDays = new Map<String, TimeRangeResult?>();
  final _defaultInitialRange = TimeRangeResult(
    TimeOfDay(hour: 8, minute: 00),
    TimeOfDay(hour: 20, minute: 00),
  );
  Widget _selectWeekdaysWidget = SizedBox();

  String _mostRecentlySelectedDay = "";
  @override
  void initState() {
    super.initState();
    for (String day in ExpertAvailabilityUtil.DAYS) {
      _selectedDays[day] = null;
    }
    refreshAvailability();
  }

  void refreshAvailability() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _hasChanges = false;
      final expertInfo = await PublicExpertInfo.get(widget.uid);
      if (expertInfo == null) {
        throw Exception('No expert info for user ${widget.uid}');
      }
      final availability = new Map<String, TimeRangeResult?>();
      for (String day in ExpertAvailabilityUtil.DAYS) {
        final utcDayAvailability =
            expertInfo.documentType.availability.getDayAvailability(day);
        availability[day] =
            convertDayAvailabilityToTimeRangeResult(utcDayAvailability);
      }
      setState(() {
        _selectedDays.addAll(availability);
        _selectWeekdaysWidget = buildSelectWeekdays(availability);
      });
    });
  }

  Widget buildSelectWeekdays(Map<String, TimeRangeResult?> availability) {
    List<DayInWeek> _days = [
      DayInWeek(ExpertAvailabilityUtil.DAYS[0],
          isSelected: availability[ExpertAvailabilityUtil.DAYS[0]] != null),
      DayInWeek(ExpertAvailabilityUtil.DAYS[1],
          isSelected: availability[ExpertAvailabilityUtil.DAYS[1]] != null),
      DayInWeek(ExpertAvailabilityUtil.DAYS[2],
          isSelected: availability[ExpertAvailabilityUtil.DAYS[2]] != null),
      DayInWeek(ExpertAvailabilityUtil.DAYS[3],
          isSelected: availability[ExpertAvailabilityUtil.DAYS[3]] != null),
      DayInWeek(ExpertAvailabilityUtil.DAYS[4],
          isSelected: availability[ExpertAvailabilityUtil.DAYS[4]] != null),
      DayInWeek(ExpertAvailabilityUtil.DAYS[5],
          isSelected: availability[ExpertAvailabilityUtil.DAYS[5]] != null),
      DayInWeek(ExpertAvailabilityUtil.DAYS[6],
          isSelected: availability[ExpertAvailabilityUtil.DAYS[6]] != null),
    ];
    return SelectWeekDays(
      key: Key(Uuid().v4()),
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
          tileMode: TileMode.repeated, // repeats the gradient over the canvas
        ),
      ),
      onSelect: onDaysSelected,
    );
  }

  TimeRangeResult? convertDayAvailabilityToTimeRangeResult(
      DayAvailability dayAvailability) {
    if (dayAvailability.isAvailable) {
      return TimeRangeResult(
        TimeOfDay(
            hour: TimezoneUtil.localHour(utcHour: dayAvailability.startHourUtc),
            minute: dayAvailability.startMinuteUtc),
        TimeOfDay(
            hour: TimezoneUtil.localHour(utcHour: dayAvailability.endHourUtc),
            minute: dayAvailability.endMinuteUtc),
      );
    }
    return null;
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
    String? newDayAdded = getNewDayAdded(newDaysSelected);
    String? newDayRemoved = getNewDayRemoved(newDaysSelected);
    if (newDayAdded == null && newDayRemoved == null) {
      throw Exception('Expecting one day to be either added or removed');
    }
    if (newDayAdded != null && newDayRemoved != null) {
      throw Exception('Only one day can be either added or removed');
    }
    _hasChanges = true;
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
    return Column(
      children: [
        SizedBox(height: 5),
        Text("Tap a day to change availability",
            style: CallSummaryUtil.BOLD_STYLE),
        SizedBox(height: 5),
        Row(
          children: [
            SizedBox(width: 10),
            Expanded(child: _selectWeekdaysWidget),
            SizedBox(width: 10),
          ],
        ),
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
        SizedBox(height: 20),
        TimeRange(
          fromTitle: Text(
            'Allow calls starting at for $_mostRecentlySelectedDay',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          toTitle: Text(
            'Do not allow calls starting at for $_mostRecentlySelectedDay',
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

  Widget buildTimeSummary() {
    ExpertAvailability currentAvailability =
        ExpertAvailabilityUtil.convertToExpertAvailability(_selectedDays);
    return ExpertAvailabilityUtil.buildTimeSummary(
        context: context,
        availability: currentAvailability,
        title: "Your availability");
  }

  Widget buildSubmitAvailabilityButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        textStyle: const TextStyle(fontSize: 20),
        shadowColor: Colors.black,
        elevation: 10,
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
        startHourUtc:
            TimezoneUtil.utcHour(localHour: dayAvailability.start.hour),
        startMinuteUtc: dayAvailability.start.minute,
        endHourUtc: TimezoneUtil.utcHour(localHour: dayAvailability.end.hour),
        endMinuteUtc: dayAvailability.end.minute);
  }

  Future<void> sendAvailability() async {
    final availability = ExpertAvailability(
      mondayAvailability:
          buildAvailabilityForDay(ExpertAvailabilityUtil.DAYS[0]),
      tuesdayAvailability:
          buildAvailabilityForDay(ExpertAvailabilityUtil.DAYS[1]),
      wednesdayAvailability:
          buildAvailabilityForDay(ExpertAvailabilityUtil.DAYS[2]),
      thursdayAvailability:
          buildAvailabilityForDay(ExpertAvailabilityUtil.DAYS[3]),
      fridayAvailability:
          buildAvailabilityForDay(ExpertAvailabilityUtil.DAYS[4]),
      saturdayAvailability:
          buildAvailabilityForDay(ExpertAvailabilityUtil.DAYS[5]),
      sundayAvailability:
          buildAvailabilityForDay(ExpertAvailabilityUtil.DAYS[6]),
    );
    final result = await updateExpertAvailability(availability);
    if (result.success) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Your availability has been updated"),
            );
          });
    } else {
      if (!result.success) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("We are experiencing technical difficulties. "
                    "Please contact customer service to update your availability."),
              );
            });
      }
    }
    refreshAvailability();
  }

  Future<bool?> buildUnsavedChangesDialog() {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Discard changes?"),
            content: Text(
                "You have unsaved changes. Are you sure you want to discard them?"),
            actions: [
              TextButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text("Yes"),
                onPressed: () {
                  refreshAvailability();
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          final shouldPop = await buildUnsavedChangesDialog();
          if (shouldPop == null) {
            return Future.value(false);
          }
          return Future.value(shouldPop);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Availability for accepting calls"),
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
      ),
    );
  }
}

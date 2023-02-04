import 'package:flutter/material.dart';
import 'package:todo/date.dart';
import 'package:jiffy/jiffy.dart';

class ScheduleType {
  final String _value;

  String get value => _value;

  const ScheduleType.periodic() : _value = "periodic";
  const ScheduleType.onDates() : _value = "onDates";

  ScheduleType.fromJson(Map<String, dynamic> json) : _value = json['value'];

  Map<String, dynamic> toJson() => {
        'value': _value,
      };
}

class PeriodType {
  final String value;

  const PeriodType.minutes() : value = "minutes";
  const PeriodType.hours() : value = "hours";
  const PeriodType.days() : value = "days";
  const PeriodType.weeks() : value = "weeks";
  const PeriodType.months() : value = "months";
  PeriodType.fromJson(Map<String, dynamic> json) : value = json['value'];

  Map<String, dynamic> toJson() => {
        'value': value,
      };

  static PeriodType from(String str) {
    switch (str) {
      case "minutes":
        return const PeriodType.minutes();
      case "hours":
        return const PeriodType.hours();
      case "days":
        return const PeriodType.days();
      case "weeks":
        return const PeriodType.weeks();
      case "months":
        return const PeriodType.months();
      default:
        assert(false, "should never happen");
        return const PeriodType.minutes();
    }
  }
}

class PeriodicTypes {
  static const List<PeriodType> all = [
    PeriodType.minutes(),
    PeriodType.hours(),
    PeriodType.days(),
    PeriodType.weeks(),
    PeriodType.months(),
  ];
}

class RepeatSchedule {
  final ScheduleType type;
  final int period;
  final PeriodType periodType;
  final List<int> dates;

  RepeatSchedule({
    this.type = const ScheduleType.periodic(),
    this.period = 1,
    this.periodType = const PeriodType.days(),
    this.dates = const [],
  });

  RepeatSchedule.fromJson(Map<String, dynamic> map)
      : type = ScheduleType.fromJson(map['type']),
        period = map['period'],
        periodType = PeriodType.fromJson(map['periodType']),
        dates = map['dates'].cast<int>();

  Date calculateNextDueDate(Date lastCompleted) {
    if (type.value == const ScheduleType.periodic().value) {
      return _calculatePeriodicNext(lastCompleted);
    } else if (type.value == const ScheduleType.onDates().value) {
      return _calculateOnDatesNext(lastCompleted);
    } else {
      throw UnsupportedError("Unknown schedule type");
    }
  }

  Date _calculateOnDatesNext(Date lastCompleted) {
    var jiffy = Jiffy(lastCompleted.dateTime);
    var lastCompletedDate = jiffy.date;
    dates.sort();
    var nextDateIndex = dates.indexWhere((date) => date > lastCompletedDate);
    var nextDate = nextDateIndex == -1 ? dates.first : dates[nextDateIndex];
    debugPrint("nextDate is $nextDate");

    while (jiffy.date != nextDate) {
      jiffy.add(days: 1);
    }

    return Date(jiffy.dateTime);
  }

  Date _calculatePeriodicNext(Date lastCompleted) {
    var jiffy = Jiffy(lastCompleted.dateTime);
    switch (periodType) {
      case PeriodType.minutes():
        jiffy.add(minutes: period);
        break;
      case PeriodType.hours():
        jiffy.add(hours: period);
        break;
      case PeriodType.days():
        jiffy.add(days: period);
        break;
      case PeriodType.weeks():
        jiffy.add(weeks: period);
        break;
      case PeriodType.months():
        jiffy.add(months: period);
        break;
      default: // minutes
        jiffy.add(minutes: period);
        break;
    }

    return Date(jiffy.dateTime);
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'period': period,
      'periodType': periodType,
      'dates': dates,
    };
  }

  RepeatSchedule copyWith({
    ScheduleType? type,
    int? period,
    PeriodType? periodType,
    List<int>? dates,
  }) =>
      RepeatSchedule(
        type: type ?? this.type,
        period: period ?? this.period,
        periodType: periodType ?? this.periodType,
        dates: dates ?? this.dates,
      );

  String get displayName {
    if (type.value == const ScheduleType.periodic().value) {
      return "Every $period ${periodType.value}";
    } else if (type.value == const ScheduleType.onDates().value) {
      return "${dates.join(", ")} of Every Month";
    } else {
      return "???";
    }
  }
}


// TODO rename break up
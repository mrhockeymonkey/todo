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

  const PeriodType.days() : value = "days";
  const PeriodType.weeks() : value = "weeks";
  const PeriodType.months() : value = "months";
  const PeriodType.years() : value = "years";

  PeriodType.fromJson(Map<String, dynamic> json) : value = json['value'];

  Map<String, dynamic> toJson() => {
        'value': value,
      };

  static const List<PeriodType> all = [
    PeriodType.days(),
    PeriodType.weeks(),
    PeriodType.months(),
    PeriodType.years(),
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
      case PeriodType.days():
        return Date(jiffy.add(days: period).dateTime);
      case PeriodType.weeks():
        return Date(jiffy.add(weeks: period).dateTime);
      case PeriodType.months():
        return Date(jiffy.add(months: period).dateTime);
      case PeriodType.years():
        return Date(jiffy.add(years: period).dateTime);
      default: // minutes
        assert(true, "should never happen!");
        return Date(jiffy.add(minutes: period).dateTime);
    }
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
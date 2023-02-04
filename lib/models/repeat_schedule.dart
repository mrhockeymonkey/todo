class RepeatScheduleTypes {
  static const String periodic = "periodic";
  static const String onDates = "ondates";
}

class PeriodType {
  final String value;

  const PeriodType._(this.value);

  static const PeriodType minutes = PeriodType._("minutes");
  static const PeriodType hours = PeriodType._("hours");
  static const PeriodType days = PeriodType._("days");
  static const PeriodType weeks = PeriodType._("weeks");
  static const PeriodType months = PeriodType._("months");
}

class PeriodicTypes {
  static const List<PeriodType> all = [
    PeriodType.minutes,
    PeriodType.hours,
    PeriodType.days,
    PeriodType.weeks,
    PeriodType.months,
  ];
}

class RepeatSchedule {
  final String type;
  final int period;
  final PeriodType periodType;
  final List<int> dates;

  RepeatSchedule({
    this.type = RepeatScheduleTypes.periodic,
    this.period = 1,
    this.periodType = PeriodType.days,
    this.dates = const [],
  });

  factory RepeatSchedule.fromMap(Map<String, dynamic> map) {
    return RepeatSchedule(
      type: map['type'],
      period: map['period'],
      periodType: map['periodType'],
      dates: map['dates'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'period': period,
      'periodType': periodType,
      'dates': dates,
    };
  }

  RepeatSchedule copyWith({
    String? type,
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

  String get displayName => type == RepeatScheduleTypes.periodic
      ? "Every $period ${periodType.value}"
      : "${dates.join(", ")} Of Every Month";
}


// TODO rename break up
class RepeatScheduleTypes {
  static const String periodic = "periodic";
  static const String onDates = "ondates";
}

class PeriodicTypes {
  static const String minutes = "minutes";
  static const String hours = "hours";
  static const String days = "days";
  static const String weeks = "weeks";
  static const String months = "months";

  static const List<String> all = [
    PeriodicTypes.minutes,
    PeriodicTypes.hours,
    PeriodicTypes.days,
    PeriodicTypes.weeks,
    PeriodicTypes.months,
  ];
}

class RepeatPickerAnswer {
  String type;
  int period;
  String periodType;
  List<int> dates;

  RepeatPickerAnswer({
    this.type = RepeatScheduleTypes.periodic,
    this.period = 1,
    this.periodType = PeriodicTypes.days,
    this.dates = const [],
  });
}


// TODO rename break up
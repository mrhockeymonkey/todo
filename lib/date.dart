import 'package:intl/intl.dart';

class Date {
  final DateTime _dateTime;

  Date(DateTime dateTime)
      : _dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day);

  Date.fromMillisecondsSinceEpoch(int milliseconds)
      : _dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  factory Date.now() {
    var now = DateTime.now();
    return Date(now);
  }

  DateTime get dateTime => _dateTime;
  int get year => _dateTime.year;
  int get month => _dateTime.month;
  int get day => _dateTime.day;
  int get millisecondsSinceEpoch => _dateTime.millisecondsSinceEpoch;

  bool isAtSameMomentAs(Date other) => _dateTime.isAtSameMomentAs(DateTime(
        other.year,
        other.month,
        other.day,
      ));

  bool isBefore(Date other) => _dateTime.isBefore(DateTime(
        other.year,
        other.month,
        other.day,
      ));

  int compareTo(Date other) => _dateTime.compareTo(other.dateTime);

  Date add(Duration duration) {
    return Date(_dateTime.add(duration));
  }

  // Adds a day tothe given date or returns tomorrow if given date is in the past
  Date addFromNow(Duration duration) {
    var now = Date.now();

    return isBefore(now) ? now.add(duration) : add(duration);
    // if (this.isBefore(now)) {
    //   return now.add(duration);
    // }
    // return this.add(duration);
  }

  @override
  String toString() => "Date: $day/$month/$year";

  @override
  bool operator ==(covariant Date other) {
    if (identical(this, other)) return true;

    return other.runtimeType == Date &&
        day == other.day &&
        month == other.month &&
        year == other.year;
  }

  String yMMMd() => DateFormat.yMMMMd('en_GB').format(_dateTime);

  @override
  int get hashCode => Object.hash(day, month, year);
}

import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  int toInt() {
    DateFormat formatter = new DateFormat('yyyyMMdd');
    String sortableStr = formatter.format(this);
    int sortableInt = int.parse(sortableStr);
    return sortableInt;
  }

  String formatString() {
    DateFormat formatter = new DateFormat.yMMMMd('en_GB');
    return formatter.format(this);
  }

  DateTime withoutTime() => new DateTime(this.year, this.month, this.day);
}

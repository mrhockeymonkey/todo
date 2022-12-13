import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  int asSortableIntDate() => int.parse(DateFormat('yyyyMMdd').format(this));

  String formatString() => DateFormat.yMMMMd('en_GB').format(this);

  DateTime withoutTime() => DateTime(year, month, day); // TODO
}

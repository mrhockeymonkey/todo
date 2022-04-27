import 'package:intl/intl.dart';
import 'package:todo/app_constants.dart';

extension DateTimeExtensions on DateTime {
  int asSortableInt() => this == null
      ? AppConstants.Later
      : int.parse(new DateFormat('yyyyMMdd').format(this));

  String formatString() => new DateFormat.yMMMMd('en_GB').format(this);

  DateTime withoutTime() =>
      new DateTime(this.year, this.month, this.day); // TODO
}

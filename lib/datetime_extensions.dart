import 'package:intl/intl.dart';
import 'package:todo/app_constants.dart';

extension DateTimeExtensions on DateTime {
  int asSortableIntDate() => this == null
      ? AppConstants.SortableIntDateMax
      : int.parse(new DateFormat('yyyyMMdd').format(this));

  String formatString() => new DateFormat.yMMMMd('en_GB').format(this);

  DateTime withoutTime() =>
      new DateTime(this.year, this.month, this.day); // TODO
}

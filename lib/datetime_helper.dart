import 'package:intl/intl.dart';

class DateTimeHelper {
  static const int LaterDate = 99999999;

  static int toSortableDate(DateTime date) {
    // make extension method
    DateFormat formatter = new DateFormat('yyyyMMdd');
    String sortableStr = formatter.format(date);
    int sortableInt = int.parse(sortableStr);
    return sortableInt;
  }

  static DateTime toDateTime(int sortableDate) {
    String strDate = sortableDate.toString();
    int year = int.parse(strDate.substring(0, 4));
    int month = int.parse(strDate.substring(4, 6));
    int day = int.parse(strDate.substring(6, 8));
    return DateTime(year, month, day);
  }

  static String formatString(DateTime date) {
    DateFormat formatter = new DateFormat.yMMMMd('en_GB');
    return formatter.format(date);
  }
}

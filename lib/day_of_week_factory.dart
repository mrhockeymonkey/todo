import 'package:todo/datetime_helper.dart';
import 'package:todo/models/pinnedDayOfWeek.dart';
import 'package:todo/models/pinnedItemBase.dart';
import 'package:todo/models/pinned_later.dart';
import 'datetime_extensions.dart';

class PinnedDayOfWeekFactory {
  static int numPinnedDays = 6;

  static DateTime getPinnedDateTimeEnd() =>
      DateTime.now().add(new Duration(days: numPinnedDays)).withoutTime();

  static List<PinnedItemBase> getPinnedDaysOfWeek() =>
      List<PinnedItemBase>.generate(
          numPinnedDays,
          (index) => PinnedDayOfWeek.fromDateTime(
              DateTime.now().add(new Duration(days: index))));
}

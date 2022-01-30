import 'package:todo/datetim_helpers.dart';
import 'package:todo/models/pinnedDayOfWeek.dart';
import 'package:todo/models/pinnedItem.dart';

class PinnedDayOfWeekFactory {
  static List<PinnedItem> getPinnedDaysOfWeek(int count) =>
      List<PinnedItem>.generate(
          count,
          (index) => PinnedDayOfWeek.fromDateTime(
              DateTime.now().add(new Duration(days: index))));
}

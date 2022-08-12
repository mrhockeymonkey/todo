import 'package:todo/models/pinnedDayOfWeek.dart';
import 'package:todo/models/pinnedItemBase.dart';
import 'package:todo/models/pinned_later.dart';
import 'package:todo/datetime_extensions.dart';
import 'package:todo/app_constants.dart';
import 'datetime_extensions.dart';

class PinnedDayOfWeekFactory {
  static DateTime getPinnedDateTimeEnd() => DateTime.now()
      .add(new Duration(days: AppConstants.NumDayToLookAhead))
      .withoutTime();

  static List<PinnedItemBase> getPinnedDaysOfWeek() {
    var now = DateTime.now();

    return List<PinnedItemBase>.generate(
        AppConstants.NumDayToLookAhead + 1,
        (index) => index < AppConstants.NumDayToLookAhead
            ? new PinnedDayOfWeek(
                date: now.add(new Duration(days: index)).asSortableIntDate(),
              )
            : new PinnedLater(
                date: now.add(new Duration(days: index)).asSortableIntDate(),
              ));
  }
}

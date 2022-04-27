import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:todo/models/pinnedItemBase.dart';
import 'package:todo/widgets/text_header.dart';
import '../datetime_helper.dart';
import 'task.dart';

class PinnedDayOfWeek extends PinnedItemBase {
  PinnedDayOfWeek({
    @required int date,
  }) : super(null, date, 0, "");

  factory PinnedDayOfWeek.fromDateTime(DateTime dateTime) =>
      PinnedDayOfWeek(date: DateTimeHelper.toSortableDate(dateTime));

  factory PinnedDayOfWeek.later() => PinnedDayOfWeek(date: 99999999);

  set date(int newDate) => print("wont set date for PinnedDayOfWeek item");

  Widget build(BuildContext context) => TextHeader(
      text: Jiffy(DateTimeHelper.toDateTime(date)).MMMMEEEEd.toString());

  @override
  void updateTask() {
    // do nothing
  }

  @override
  int getNextDate(int currentDate) => date;

  @override
  int getNextOrder(int currentOrder) => 0;

  @override
  Task getTask() => null;

  @override
  String toString() => "Day of week ($date)";
}

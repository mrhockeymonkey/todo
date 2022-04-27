import 'package:flutter/src/widgets/framework.dart';
import 'package:todo/app_constants.dart';
import 'package:todo/datetime_extensions.dart';
import 'package:todo/int_extensions.dart';
import 'package:todo/models/pinnedItemBase.dart';
import 'package:todo/models/task.dart';
import 'package:todo/widgets/text_header.dart';

class PinnedLater extends PinnedItemBase {
  PinnedLater({
    @required int date,
  }) : super(null, date, -1, "");

  set date(int newDate) => print("wont set date for PinnedLater item");

  @override
  Widget build(BuildContext context) => TextHeader(text: "Later... $date");

  @override
  void updateTask() {
    // do nothing
  }

  @override
  int getNextDate(int currentDate) => date;

  @override
  int getNextOrder(int currentOrder) => 1;

  @override
  Task getTask() => null;

  @override
  String toString() => "PinnedLater";
}

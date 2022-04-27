import 'package:flutter/src/widgets/framework.dart';
import 'package:todo/int_extensions.dart';
import 'package:todo/models/pinnedItemBase.dart';
import 'package:todo/models/task.dart';
import 'package:todo/widgets/text_header.dart';

class PinnedMissed extends PinnedItemBase {
  PinnedMissed() : super(null, 0, 0, "");

  set date(int newDate) => print("wont set date for PinnedMissed item");

  @override
  Widget build(BuildContext context) => TextHeader(text: "Missed... $date");

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

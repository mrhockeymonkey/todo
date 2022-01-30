import 'package:flutter/material.dart';
import 'package:todo/models/pinnedItem.dart';
import '../datetim_helpers.dart';
import 'task.dart';

class PinnedDayOfWeek extends PinnedItem {
  Task task;
  int date;
  int order = 0;

  PinnedDayOfWeek({
    @required this.date,
  }) {
    task = new Task(id: null, title: "DayOfWeek $date");
  }

  factory PinnedDayOfWeek.fromDateTime(DateTime dateTime) =>
      PinnedDayOfWeek(date: DateTimeConvert.toSortableDate(dateTime));

  Widget build(BuildContext context) => ListTile(
        title: Text(task.title),
        subtitle: Text("date: $date, order: $order"),
      );

  @override
  void updateTask() {
    // do nothing
  }

  @override
  Task getTask() => null;
}

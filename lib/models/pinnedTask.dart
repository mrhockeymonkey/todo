import 'package:flutter/material.dart';
import 'package:todo/datetime_extensions.dart';
import 'package:todo/int_extensions.dart';
import 'task.dart';
import 'pinnedItemBase.dart';
import '../widgets/task_item.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:provider/provider.dart';

class PinnedTask extends PinnedItemBase {
  PinnedTask({
    @required Task task,
  }) : super(
          task,
          task.dueDate.asSortableInt(),
          task.pinnedOrder,
          type,
        );

  static String get type => "task";

  Widget build(BuildContext context) => Dismissible(
        key: Key(task.id),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) => _handleDismiss(context, direction, task),
        child: TaskItem(task: task),
      );

  void _handleDismiss(
      BuildContext context, DismissDirection direction, Task task) {
    task.done();
    Provider.of<TaskProvider>(context, listen: false).addOrUpdate(task);
  }

  @override
  void updateTask() {
    task.dueDate = date.asDateTime();
    task.pinnedOrder = order;
  }

  @override
  int getNextDate(int currentDate) => currentDate;

  @override
  int getNextOrder(int currentOrder) => currentOrder + 1;

  @override
  Task getTask() => task;

  @override
  String toString() => "PinnedTask: ${task.title}";
}

import 'package:flutter/material.dart';
import 'task.dart';
import 'pinnedItem.dart';
import '../widgets/task_item.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:provider/provider.dart';

class PinnedTask extends PinnedItem {
  final Task task;
  int date;
  int order;

  PinnedTask({
    @required this.task,
  }) {
    date = task.pinnedDayOfWeek;
    order = task.pinnedOrder;
  }

  //Widget build() => TaskItem(task: task);

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
    task.pinnedDayOfWeek = date;
    task.pinnedOrder = order;
  }

  @override
  Task getTask() => task;
}

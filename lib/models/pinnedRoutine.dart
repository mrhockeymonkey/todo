import 'package:provider/provider.dart';
import 'package:todo/int_extensions.dart';
import 'package:todo/models/pinnedItemBase.dart';
import 'package:flutter/material.dart';
import 'package:todo/models/routine.dart';
import 'package:todo/models/task.dart';
import 'package:todo/widgets/task_item.dart';
import 'package:todo/datetime_extensions.dart';
import 'package:uuid/uuid.dart';

import '../providers/routine_provider.dart';
import '../widgets/routine_item.dart';

class PinnedRoutine extends PinnedItemBase {
  final Routine routine;

  PinnedRoutine(Routine routine)
      : this.routine = routine,
        super(
          new Task(id: "id", title: routine.title), // TODO this sucks
          routine.nextDueDate.asSortableInt(),
          0,
          type,
        );

  static String get type => "task";

  // @override
  // Widget build(BuildContext context) => TaskItem(task: task);
  @override
  Widget build(BuildContext context) => Dismissible(
        key: Key(Uuid().v1()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) => _handleDismiss(context, direction, routine),
        child: RoutineItem(routine: routine),
      );

  void _handleDismiss(
      BuildContext context, DismissDirection direction, Routine routine) {
    routine.done();
    Provider.of<RoutineProvider>(context, listen: false).addOrUpdate(routine);
  }

  @override
  int getNextDate(int currentDate) => currentDate;

  @override
  int getNextOrder(int currentOrder) => currentOrder + 1;

  @override
  void updateTask() {
    routine.nextDueDate = date.asDateTime();
    // include pinned order??
  }

  @override
  String toString() => "PinnedRoutine: ${task.title}";
}

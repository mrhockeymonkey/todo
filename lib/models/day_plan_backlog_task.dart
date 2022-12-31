import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/day_plan_base.dart';
import 'package:todo/models/task.dart';
import 'package:todo/widgets/flagged_icon.dart';
import 'package:uuid/uuid.dart';

import '../app_colour.dart';
import '../providers/category_provider.dart';
import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';
import 'category.dart';
import 'day_plan_actions.dart';

class DayPlanBacklogTask extends DayPlanBase<Task> {
  final Task task;
  bool showButtons = false;

  DayPlanBacklogTask({required this.task});

  @override
  Widget build(BuildContext context) {
    var categoryId = task.categoryId;
    var category = categoryId == null
        ? Category.defaultCategory()
        : Provider.of<CategoryProvider>(context).getItemById(categoryId);

    return Dismissible(
      key: Key(const Uuid().v1()),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => _handleDismiss(context, direction),
      child: ListTile(
        key: ValueKey(task.id),
        title: Text(
          task.title,
          style: task.isDone
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                )
              : null,
        ),
        leading: task.isDone
            ? Icon(category.icon, color: category.color)
            : FlaggedIcon(
                icon: category.icon,
                color: category.color,
                showFlag: task.isFlagged),
        trailing: DayPlanActions(
          handleSnooze: _handleSnooze,
          handleFlag: _handleFlag,
        ),
        subtitle: showButtons
            ? Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.air)),
                ],
              )
            : null,
        isThreeLine: false,
        onTap: () => Navigator.of(context)
            .pushNamed(TaskDetailScreen.routeName, arguments: task.id),
      ),
    );
  }

  void _handleDismiss(BuildContext context, DismissDirection direction) =>
      Provider.of<TaskProvider>(context, listen: false)
          .addOrUpdate(task.done());

  void _handleSnooze(BuildContext context) {
    if (task.dueDate == null) return;

    var oneDay = const Duration(days: 1);
    var snoozedTask = task.copyWith(dueDate: task.dueDate!.addFromNow(oneDay));

    Provider.of<TaskProvider>(context, listen: false).addOrUpdate(snoozedTask);
  }

  void _handleFlag(BuildContext context) =>
      Provider.of<TaskProvider>(context, listen: false)
          .addOrUpdate(task.copyWith(isFlagged: !task.isFlagged));

  @override
  int get order => task.order;

  @override
  String toString() => "$runtimeType: ${task.title}";

  @override
  Type get itemtype => runtimeType;

  @override
  Task get item => task;

  @override
  bool get isDone => task.isDone;

  @override
  bool get isFlagged => task.isFlagged;
}

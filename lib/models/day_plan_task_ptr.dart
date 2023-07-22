import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/day_plan_base.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models/throw_away_task.dart';
import 'package:todo/widgets/flagged_icon.dart';
import 'package:uuid/uuid.dart';

import '../app_colour.dart';
import '../providers/category_provider.dart';
import '../providers/task_provider.dart';
import '../providers/throw_away_task_provider.dart';
import '../screens/task_detail_screen.dart';
import 'category.dart';
import 'day_plan_actions.dart';

class DayPlanTaskPtr extends DayPlanBase {
  final Task task;

  DayPlanTaskPtr({
    required ThrowAwayTask todo,
    required this.task,
  }) : super(item: todo);

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
            ? Icon(Icons.check, color: Colors.grey[350])
            : FlaggedIcon(
                icon: category.icon,
                color: category.color,
                showFlag: task.isFlagged),
        trailing: DayPlanActions(
          handleSnooze: _handleSnooze,
          handleFlag: _handleFlag,
          handleRemove: _handleRemove,
        ),
        isThreeLine: false,
        onTap: () => Navigator.of(context)
            .pushNamed(TaskDetailScreen.routeName, arguments: task.id),
      ),
    );
  }

  void _handleDismiss(BuildContext context, DismissDirection direction) {
    Provider.of<ThrowAwayTaskProvider>(context, listen: false)
        .addOrUpdate(super.item.done());
    Provider.of<TaskProvider>(context, listen: false).addOrUpdate(task.done());
    //TODO notify after both?
  }

  void _handleSnooze(BuildContext context) {
    var oneDay = const Duration(days: 1);
    var newDate = super.item.date.addFromNow(oneDay);

    var snoozedToDo = super.item.copyWith(date: newDate);
    var snoozedTask = task.copyWith(dueDate: newDate);

    Provider.of<ThrowAwayTaskProvider>(context, listen: false)
        .addOrUpdate(snoozedToDo);
    Provider.of<TaskProvider>(context, listen: false).addOrUpdate(snoozedTask);
  }

  void _handleFlag(BuildContext context) =>
      Provider.of<TaskProvider>(context, listen: false)
          .addOrUpdate(task.copyWith(isFlagged: !task.isFlagged));

  void _handleRemove(BuildContext context) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false)
          .delete(super.item.id!);
}

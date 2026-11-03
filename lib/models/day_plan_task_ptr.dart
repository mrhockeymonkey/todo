import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/celebration/celebration_controller.dart';
import 'package:todo/celebration/celebration_effect.dart';
import 'package:todo/celebration/celebration_style.dart';
import 'package:todo/celebration/celebration_target.dart';
import 'package:todo/models/day_plan_base.dart';
import 'package:todo/models/task.dart';
import 'package:todo/widgets/flagged_icon.dart';
import 'package:todo/widgets/priority_menu.dart';
import '../providers/category_provider.dart';
import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';
import 'category.dart';
import 'priority.dart';
import 'day_plan_actions.dart';

class DayPlanTaskPtr extends DayPlanBase {
  final Task task;

  DayPlanTaskPtr({
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    var categoryId = task.categoryId;
    var category = categoryId == null
        ? Category.defaultCategory()
        : Provider.of<CategoryProvider>(context).getItemById(categoryId);

    // The Builder gives a context for this row, so the celebration knows
    // where the row was when it was swiped.
    return Builder(
      builder: (itemContext) => Dismissible(
        // ObjectKey: the provider returns the same instance until the item is
        // saved, and every save creates a new one, so a dismissed tile always
        // comes back with fresh state (a stable id key would trip
        // Dismissible's "dismissed widget is still part of the tree"
        // assertion).
        key: ObjectKey(task),
        direction: DismissDirection.startToEnd,
        // Start the celebration as soon as the swipe is let go, while the row
        // is still laid out where the user saw it.
        confirmDismiss: (_) async {
          _celebrate(itemContext, category);
          return true;
        },
        onDismissed: (direction) => _handleDismiss(context, direction),
        child: CelebrationTarget(
          taskId: task.id,
          enabled: task.isDone,
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
                : PriorityMenu(
                    onSelected: (priority) =>
                        _handlePriority(context, priority),
                    child: FlaggedIcon(
                        icon: category.icon,
                        color: task.priority.color,
                        showFlag: task.isFlagged),
                  ),
            trailing: DayPlanActions(
              handleSnooze: _handleSnooze,
              handleFlag: _handleFlag,
              //handleRemove: _handleRemove,
            ),
            isThreeLine: false,
            onTap: () => Navigator.of(context)
                .pushNamed(TaskDetailScreen.routeName, arguments: task.id),
          ),
        ),
      ),
    );
  }

  void _celebrate(BuildContext itemContext, Category category) {
    final id = task.id;
    final controller =
        Provider.of<CelebrationController?>(itemContext, listen: false);
    final box = itemContext.findRenderObject();
    if (task.isDone || id == null || controller == null) return;
    if (box is! RenderBox || !box.hasSize) return;

    final settings =
        Provider.of<CelebrationSettings?>(itemContext, listen: false);
    controller.celebrate(
      itemContext,
      style: settings?.style ?? CelebrationStyle.circuit,
      request: CelebrationRequest(
        taskId: id,
        title: task.title,
        colour: category.color,
        source: box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  void _handleDismiss(BuildContext context, DismissDirection direction) {
    Provider.of<TaskProvider>(context, listen: false).addOrUpdate(task.done());
  }

  void _handleSnooze(BuildContext context) {
    var oneDay = const Duration(days: 1);
    var newDate = task.dueDate?.add(oneDay);

    var snoozedTask = task.copyWith(dueDate: newDate);

    Provider.of<TaskProvider>(context, listen: false).addOrUpdate(snoozedTask);
  }

  void _handleFlag(BuildContext context) =>
      Provider.of<TaskProvider>(context, listen: false)
          .addOrUpdate(task.copyWith(isFlagged: !task.isFlagged));

  void _handlePriority(BuildContext context, Priority priority) =>
      Provider.of<TaskProvider>(context, listen: false)
          .addOrUpdate(task.copyWith(priority: priority));
          
  @override
  bool get isDone => task.isDone;

  @override
  bool get isFlagged => task.isFlagged;

  @override
  int get order => task.order;
}

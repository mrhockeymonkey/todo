import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/day_plan_base.dart';
import 'package:todo/models/task.dart';
import 'package:uuid/uuid.dart';

import '../app_colour.dart';
import '../app_constants.dart';
import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';
import 'category.dart';

class DayPlanBacklogTask extends DayPlanBase<Task> {
  final Task task;

  DayPlanBacklogTask({required this.task});

  @override
  Widget build(BuildContext context) => Dismissible(
        key: Key(Uuid().v1()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) => _handleDismiss(context, direction, task),
        child: ListTile(
          key: ValueKey(task.id),
          title: Text(
            task.title,
            style: task.isDone
                ? TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  )
                : null,
          ),
          leading: task.isDone
              ? Icon(Entypo.pin, color: Colors.grey[350])
              : Icon(Category.defaultIcon, color: AppColour.colorCustom),
          trailing: Icon(AppConstants.DragIndicator),
          isThreeLine: false,
          onTap: () => Navigator.of(context)
              .pushNamed(TaskDetailScreen.routeName, arguments: task.id),
        ),
      );

  void _handleDismiss(
    BuildContext context,
    DismissDirection direction,
    Task task,
  ) {
    Provider.of<TaskProvider>(context, listen: false)
        .addOrUpdate(task.copyWith(isDone: true));
  }

  @override
  int get order => task.order;

  @override
  String toString() => "${this.runtimeType}: ${task.title}";

  @override
  Type get itemtype => this.runtimeType;

  @override
  Task get item => task;
}

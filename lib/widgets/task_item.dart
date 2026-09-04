import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/category.dart';

import 'package:todo/models/task.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/providers/throw_away_task_provider.dart';
import 'package:todo/screens/task_detail_screen.dart';
import 'package:todo/widgets/add_to_dayplan_icon.dart';

import '../date.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    var categoryId = task.categoryId;
    var category = categoryId == null
        ? Category.defaultCategory()
        : Provider.of<CategoryProvider>(context).getItemById(categoryId);

    return task.isDone
        ? _buildDoneTaskItem(context, category)
        : _buildToDoTaskItem(context, category);
  }

  Widget _buildToDoTaskItem(BuildContext context, Category category) {
    return ListTile(
      key: ValueKey(task),
      title: Text(task.title),
      subtitle: task.dueDate != null
          ? Text(task.dueDate!.yMMMd())
          : const Text("At Some Point"),
      leading: Icon(category.icon, color: category.color),
      trailing: _buildPopupMenu(context),
      onTap: () => Navigator.of(context)
          .pushNamed(TaskDetailScreen.routeName, arguments: task.id),
    );
  }

  Widget _buildDoneTaskItem(BuildContext context, Category category) =>
      ListTile(
        key: const ValueKey(0),
        title: Text(
          task.title,
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
        leading: const Icon(Icons.check),
        trailing: IconButton(
          icon: const Icon(Icons.undo),
          onPressed: () {
            Provider.of<TaskProvider>(context, listen: false)
                .addOrUpdate(task.copyWith(isDone: false));
          },
        ),
      );

  Widget _buildPopupMenu(BuildContext context) => PopupMenuButton<void>(
        onSelected: (_) => {},
        itemBuilder: (context) => <PopupMenuEntry<void>>[
          PopupMenuItem<void>(
            child: ListTile(
              title: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleFlag(context);
                      },
                      icon: const Icon(Entypo.flag)),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleSnooze(context);
                      },
                      icon: const Icon(Icons.snooze)),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleAddToPlan(context);
                      },
                      icon: const AddToDayPlanIcon())
                ],
              ),
            ),
          ),
        ],
      );

  void _handleSnooze(BuildContext context) {
    if (task.dueDate == null) return;

    var oneDay = const Duration(days: 1);
    var snoozedTask = task.copyWith(dueDate: task.dueDate!.add(oneDay));

    Provider.of<TaskProvider>(context, listen: false).addOrUpdate(snoozedTask);
  }

  void _handleFlag(BuildContext context) =>
      Provider.of<TaskProvider>(context, listen: false)
          .addOrUpdate(task.copyWith(isFlagged: !task.isFlagged));

  void _handleAddToPlan(BuildContext context) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false)
          .addFromTask(task, Date.now());
}

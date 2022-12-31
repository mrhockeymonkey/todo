import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/models/category.dart';

import 'package:todo/models/task.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/screens/task_detail_screen.dart';

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
}

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

  TaskItem({required this.task});

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
          : Text("At Some Point"),
      leading: Icon(Category.defaultIcon, color: AppColour.colorCustom),
      onTap: () => Navigator.of(context)
          .pushNamed(TaskDetailScreen.routeName, arguments: task.id),

      // trailing: IconButton(
      //   icon: Icon(
      //     Entypo.pin,
      //     color: task.isPinned
      //         ? AppColour.pinActiveColor
      //         : AppColour.InactiveColor,
      //   ),
      // onPressed: () {
      //   task.isPinned = !task.isPinned;
      //   Provider.of<TaskProvider>(context, listen: false).addOrUpdate(task);
      // },
      // ),
    );
  }

  Widget _buildDoneTaskItem(BuildContext context, Category category) =>
      ListTile(
        key: ValueKey(0),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
        leading: Icon(Icons.check),
        trailing: IconButton(
          icon: Icon(Icons.undo),
          onPressed: () {
            Provider.of<TaskProvider>(context, listen: false)
                .addOrUpdate(task.copyWith(isDone: false));
          },
        ),
      );
}

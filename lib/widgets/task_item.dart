import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/models/category.dart';

import 'package:todo/models/task.dart';
import 'package:todo/models/task_detail_args.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/screens/task_detail_screen.dart';

import '../date.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  TaskItem({@required this.task});

  @override
  Widget build(BuildContext context) {
    var category =
        Provider.of<CategoryProvider>(context).getItemById(task.categoryId) ??
            new Category(id: null, name: "");
    return task.isDone
        ? _buildDoneTaskItem(context, category)
        : _buildToDoTaskItem(context, category);
  }

  Widget _buildToDoTaskItem(BuildContext context, Category category) {
    return ListTile(
      key: ValueKey(task),
      title: Text(task.title),
      subtitle: Row(
        children: [
          category.id != null
              ? Icon(
                  category.icon,
                  size: 15,
                  color: category.color,
                )
              : Container(),
          Text(" ${category.name}")
        ],
      ),
      // subtitle: task.isPinned
      //     ? Container(
      //         alignment: AlignmentDirectional.centerStart,
      //         child: Icon(
      //           Entypo.pin,
      //           size: 15,
      //           color: AppColour.pinActiveColor,
      //         ),
      //       )
      //     : null,
      leading: Icon(Category.defaultIcon, color: AppColour.colorCustom),
      trailing: Text(task.order.toString()),
      onTap: () => Navigator.of(context).pushNamed(
        TaskDetailScreen.routeName,
        arguments: TaskDetailArgs(task.id, new Date(DateTime.now())),
      ),
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

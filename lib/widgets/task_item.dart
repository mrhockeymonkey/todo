import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/models/category.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/pinnedDayOfWeek.dart';

import 'package:todo/models/task.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/screens/task_detail_screen.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  Category category;

  TaskItem({@required this.task});

  @override
  Widget build(BuildContext context) {
    category =
        Provider.of<CategoryProvider>(context).getItemById(task.categoryId) ??
            new Category(id: null, name: "foo cat");
    return task.isDone
        ? _buildDoneTaskItem(context)
        : _buildToDoTaskItem(context);
  }

  Widget _buildToDoTaskItem(BuildContext context) {
    var dateFmt =
        new DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag());

    return ListTile(
      key: ValueKey(task),
      title: Text(task.title),
      subtitle: task.dueDate != null
          ? Row(
              children: [
                Icon(
                  Icons.today,
                  size: 15.0,
                  color: task.isDue ? category.color : Colors.grey,
                ),
                Text(" ${dateFmt.format(task.dueDate)}"),
                Text("${task.pinnedDayOfWeek}-${task.pinnedOrder} "),
              ],
            )
          : Text("${task.pinnedDayOfWeek}-${task.pinnedOrder} "),
      leading: Icon(category.icon, color: category.color),
      onTap: () => Navigator.of(context).pushNamed(
        TaskDetailScreen.routeName,
        arguments: task.id,
      ),
      trailing: IconButton(
        icon: Icon(
          Entypo.pin,
          color: task.isPinned
              ? AppColour.pinActiveColor
              : AppColour.InactiveColor,
        ),
        onPressed: () {
          task.isPinned = !task.isPinned;
          Provider.of<TaskProvider>(context, listen: false).addOrUpdate(task);
        },
      ),
    );
  }

  Widget _buildDoneTaskItem(BuildContext context) => ListTile(
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
            task.toDo();
            Provider.of<TaskProvider>(context, listen: false).addOrUpdate(task);
          },
        ),
      );
}

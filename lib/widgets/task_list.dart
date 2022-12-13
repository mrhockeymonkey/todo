import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/task.dart';
import 'package:todo/providers/category_provider.dart';

import 'package:todo/providers/task_provider.dart';
import 'package:todo/widgets/task_item.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<StatefulWidget> createState() => TaskListState();
}

class TaskListState extends State<TaskList> {
  @override
  void initState() {
    //Provider.of<TaskProvider>(context, listen: false).fetch();
    //Provider.of<CategoryProvider>(context, listen: false).fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Build: TaskList");
    var tasks = Provider.of<TaskProvider>(context).items;
    final categoryProvider = Provider.of<CategoryProvider>(context);

    tasks.sort((a, b) {
      final ac = categoryProvider.getCategoryOrDefault(a.categoryId);
      final bc = categoryProvider.getCategoryOrDefault(a.categoryId);
      return ac.order.compareTo(bc.order);
    });

    var dueTasks = tasks.where((element) => element.isDue).toList();
    var doneTasks = tasks.where((element) => element.isDone).toList();
    var otherTasks = tasks
        .where((element) =>
            !dueTasks.contains(element) && !doneTasks.contains(element))
        .toList();

    tasks = dueTasks + otherTasks + doneTasks;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          Task task = tasks[index];
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) => _handleDismiss(direction, task),
            child: TaskItem(task: task),
          );
        },
        childCount: tasks.length,
      ),
    );
  }

  void _handleDismiss(DismissDirection direction, Task task) =>
      Provider.of<TaskProvider>(context, listen: false)
          .addOrUpdate(task.copyWith(isDone: true));
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/category.dart';
import 'package:todo/models/task.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:collection/collection.dart';

import 'package:todo/providers/task_provider.dart';
import 'package:todo/widgets/task_item.dart';

class TaskList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new TaskListState();
}

class TaskListState extends State<TaskList> {
  @override
  void initState() {
    Provider.of<TaskProvider>(context, listen: false).fetch();
    Provider.of<CategoryProvider>(context, listen: false).fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Build: TaskList");
    var tasks = Provider.of<TaskProvider>(context).items;
    final categoryProvider = Provider.of<CategoryProvider>(context);
    print(tasks.length);

    tasks.sort((a, b) {
      final ac = categoryProvider.getItemById(a.categoryId) ??
          Category.defaultCategory();
      final bc = categoryProvider.getItemById(b.categoryId) ??
          Category.defaultCategory();
      return ac.order.compareTo(bc.order);
    });

    var dueTasks = tasks.where((element) => element.isDue).toList();
    var doneTasks = tasks.where((element) => element.isDone).toList();
    var otherTasks = tasks
        .where((element) =>
            !dueTasks.contains(element) && !doneTasks.contains(element))
        .toList();

    tasks = dueTasks + otherTasks + doneTasks;

    print(tasks.length);

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

  void _handleDismiss(DismissDirection direction, Task task) {
    task.done();
    Provider.of<TaskProvider>(context, listen: false).addOrUpdate(task);
    setState(() {
      // trigger rebuild of the list so we can see the done task appear below
    });
  }
}

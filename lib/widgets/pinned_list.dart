import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/category.dart';
import 'package:todo/models/task.dart';
import 'package:todo/providers/category_provider.dart';

import 'package:todo/providers/task_provider.dart';
import 'package:todo/widgets/task_item.dart';

class PinnedList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new PinnedListState();
}

class PinnedListState extends State<PinnedList> {
  @override
  void initState() {
    Provider.of<TaskProvider>(context, listen: false).fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Build: PinnedList");
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.pinnedItems;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          Task task = tasks[index];
          return Dismissible(
            key: Key(task.id),
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
  }
}

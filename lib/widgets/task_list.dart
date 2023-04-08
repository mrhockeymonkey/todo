
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/task.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/widgets/task_item.dart';

class TaskList extends StatefulWidget {
  final List<Task> tasks;

  const TaskList({super.key, required this.tasks});

  @override
  State<StatefulWidget> createState() => TaskListState();
}

class TaskListState extends State<TaskList> {
  @override
  void initState() => super.initState();

  @override
  Widget build(BuildContext context) {
    // no dueDate set appears on top and then sorted by dueDate ascending
    // tasks.sort(((a, b) {
    //   if (a.dueDate == null) return -1;
    //   if (b.dueDate == null) return 1;
    //   return a.dueDate!.compareTo(b.dueDate!);
    // }));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          Task task = widget.tasks[index];
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) => _handleDismiss(direction, task),
            child: TaskItem(task: task),
          );
        },
        childCount: widget.tasks.length,
      ),
    );
  }

  void _handleDismiss(DismissDirection direction, Task task) =>
      Provider.of<TaskProvider>(context, listen: false)
          .addOrUpdate(task.copyWith(isDone: true));
}

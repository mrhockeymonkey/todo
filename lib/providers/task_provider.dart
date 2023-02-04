import 'package:flutter/foundation.dart';
import 'package:todo/models/task.dart';
import 'package:todo/providers/provider_base.dart';

import '../date.dart';

class TaskProvider extends ProviderBase<Task> {
  TaskProvider({
    required String tableName,
  }) : super(tableName: tableName);

  @override
  Task parse(Map<String, dynamic> json) => Task.fromJson(json);

  @override
  List<Task> get items {
    var items = [...super.items];
    return items;
  }

  int get isDueCount => items.where((r) => r.isDue).length;

  Future<void> clearCompletedTasks() async {
    items.where((element) => element.isDone).forEach((task) async {
      if (task.id != null) {
        debugPrint("Deleting task '${task.id}': ${task.title}");
        await delete(task.id!, notify: false);
      }
    });
    notifyListeners();
  }

  Iterable<Task> getByDate(Date date, {includeOutstanding = false}) => items
      .where(
        (t) => t.dueDate != null,
      )
      .where(
        (t) =>
            t.dueDate!.isAtSameMomentAs(date) ||
            (includeOutstanding && !t.isDone && t.dueDate!.isBefore(date)),
      );
}

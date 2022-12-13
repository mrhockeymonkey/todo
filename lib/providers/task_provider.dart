import 'package:flutter/foundation.dart';
import 'package:todo/models/task.dart';
import 'package:todo/providers/provider_base.dart';

import '../date.dart';

class TaskProvider extends ProviderBase<Task> {
  TaskProvider({
    required String tableName,
  }) : super(tableName: tableName);

  @override
  Task parse(Map<String, dynamic> json) => Task.fromMap(json);

  @override
  List<Task> get items {
    var items = [...super.items];
    return items;
  }

  int get isDueCount => items.where((r) => r.isDue).length;

  Future<void> clearCompletedTasks() async {
    items.where((element) => element.isDone).forEach((task) async {
      debugPrint("Deleting task '${task.id}': ${task.title}");
      await delete(task.id!, notify: false); // TODO dont like !
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

  // Task getRoutineById(String id) => _items[id];

  // Future<void> fetch() async {
  //   var fetched = await _db.collection(_tasks).get();
  //   fetched?.entries?.forEach((element) {
  //     final item = Task.fromMap(element.value);
  //     debugPrint(element.value);
  //     _items.putIfAbsent(item.id, () => item);
  //   });
  //   notifyListeners();
  // }

  // void delete(String id) async {
  //   debugPrint("[Deleted] '$id'");
  //   await _db.collection(_tasks).doc(id).delete();
  //   _items.remove(id);
  //   notifyListeners();
  // }

  // void addOrUpdate(Task task) async {
  //   if (task.id == null) {
  //     var taskMap = task.toMap();
  //     taskMap['id'] = _db.collection(_tasks).doc().id;
  //     task = Task.fromMap(taskMap);
  //     debugPrint("[New] '${task.toString()}'");
  //   }

  //   await _db.collection(_tasks).doc(task.id).set(task.toMap());
  //   _items[task.id] = task;
  //   debugPrint("[Saved] '${task.toString()}'");
  //   notifyListeners();
  // }
}

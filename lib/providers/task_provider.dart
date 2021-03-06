import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';

import 'package:todo/models/task.dart';
import 'package:todo/providers/provider_base.dart';

class TaskProvider extends ProviderBase<Task> {
  TaskProvider({String tableName}) : super(tableName: tableName);

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
      print("Deleting task '${task.id}': ${task.title}");
      await this.delete(task.id, notify: false);
    });
    notifyListeners();
  }

  // Task getRoutineById(String id) => _items[id];

  // Future<void> fetch() async {
  //   var fetched = await _db.collection(_tasks).get();
  //   fetched?.entries?.forEach((element) {
  //     final item = Task.fromMap(element.value);
  //     print(element.value);
  //     _items.putIfAbsent(item.id, () => item);
  //   });
  //   notifyListeners();
  // }

  // void delete(String id) async {
  //   print("[Deleted] '$id'");
  //   await _db.collection(_tasks).doc(id).delete();
  //   _items.remove(id);
  //   notifyListeners();
  // }

  // void addOrUpdate(Task task) async {
  //   if (task.id == null) {
  //     var taskMap = task.toMap();
  //     taskMap['id'] = _db.collection(_tasks).doc().id;
  //     task = Task.fromMap(taskMap);
  //     print("[New] '${task.toString()}'");
  //   }

  //   await _db.collection(_tasks).doc(task.id).set(task.toMap());
  //   _items[task.id] = task;
  //   print("[Saved] '${task.toString()}'");
  //   notifyListeners();
  // }
}

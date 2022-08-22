import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';

import 'package:todo/models/task.dart';
import 'package:todo/providers/provider_base.dart';

import '../models/throw_away_task.dart';

class ThrowAwayTaskProvider extends ProviderBase<ThrowAwayTask> {
  ThrowAwayTaskProvider({String tableName}) : super(tableName: tableName);

  @override
  ThrowAwayTask parse(Map<String, dynamic> json) => ThrowAwayTask.fromMap(json);

  @override
  List<ThrowAwayTask> get items {
    var items = [...super.items];
    return items;
  }

  List<ThrowAwayTask> getByDate(DateTime dateTime) {
    DO THIS NEXT
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

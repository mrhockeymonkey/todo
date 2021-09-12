import 'package:flutter/material.dart';
import 'package:todo/providers/db_item.dart';

class Task extends DbItem {
  final String id;
  String title;
  String categoryId;
  bool isDone;
  bool isPinned;
  DateTime dueDate;

  Task({
    @required this.id,
    @required this.title,
    this.categoryId,
    this.isDone = false,
    this.isPinned = false,
    this.dueDate,
  });

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        title: map['title'],
        categoryId: map['categoryId'] ?? null,
        isDone: map['isDone'] ?? false,
        isPinned: map['isPinned'] ?? false,
        dueDate: map['dueDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'categoryId': categoryId,
        'isDone': isDone,
        'isPinned': isPinned,
        'dueDate': dueDate.millisecondsSinceEpoch,
      };

  void done() {
    isDone = true;
  }

  void toDo() {
    isDone = false;
  }

  bool get isDue {
    if (dueDate == null) {
      return false;
    }

    return dueDate.isBefore(DateTime.now()) ? true : false;
  }

  String toString() => "Task = {id: '$id', title: '$title', isDone: '$isDone'}";
}

import 'package:flutter/material.dart';
import 'package:todo/providers/db_item.dart';

class Task extends DbItem {
  final String id;
  String title;
  String categoryId;
  bool isDone;
  bool isPinned;
  DateTime dueDate;
  int pinnedOrder;
  String notes;

  Task({
    @required this.id,
    @required this.title,
    this.categoryId,
    this.isDone = false,
    this.isPinned = false,
    this.dueDate,
    this.pinnedOrder = 1,
    this.notes = "",
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
        pinnedOrder: map['pinnedOrder'] ?? 0,
        notes: map['notes'] ?? "",
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'categoryId': categoryId,
        'isDone': isDone,
        'isPinned': isPinned,
        'dueDate': dueDate?.millisecondsSinceEpoch,
        'pinnedOrder': pinnedOrder,
        'notes': notes,
      };

  void done() {
    isDone = true;
  }

  void toDo() {
    isDone = false;
  }

  bool get isDue {
    if (dueDate == null || isDone) {
      return false;
    }

    return dueDate.isBefore(DateTime.now()) ? true : false;
  }

  bool isPinnedOrUpcoming(DateTime lookAheadDate) {
    if (isDone) {
      return false;
    }

    if (isPinned) {
      return true;
    }

    if (dueDate != null && dueDate.isBefore(lookAheadDate)) {
      return true;
    }

    return false;
  }

  String toString() => "Task = {id: '$id', title: '$title', isDone: '$isDone'}";
}

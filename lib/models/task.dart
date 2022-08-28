import 'package:flutter/material.dart';
import 'package:todo/providers/db_item.dart';

import '../date.dart';

class Task extends DbItem {
  final String id;
  final String title;
  final String categoryId;
  final bool isDone;
  final bool isPinned;
  final Date dueDate;
  final int order;
  final String notes;

  const Task({
    @required this.id,
    @required this.title,
    this.categoryId,
    this.isDone = false,
    this.isPinned = false,
    this.dueDate,
    this.order = 0,
    this.notes = "",
  });

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        title: map['title'],
        categoryId: map['categoryId'] ?? null,
        isDone: map['isDone'] ?? false,
        isPinned: map['isPinned'] ?? false,
        dueDate: map['dueDate'] != null
            ? Date.fromMillisecondsSinceEpoch(map['dueDate'])
            : null,
        order: map['order'] ?? 0,
        notes: map['notes'] ?? "",
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'categoryId': categoryId,
        'isDone': isDone,
        'isPinned': isPinned,
        'dueDate': dueDate?.millisecondsSinceEpoch,
        'order': order,
        'notes': notes,
      };

  Task copyWith({
    String title,
    bool isDone,
    int order,
  }) =>
      Task(
        id: this.id,
        title: title ?? this.title,
        categoryId: this.categoryId,
        isDone: isDone ?? this.isDone,
        isPinned: this.isPinned,
        dueDate: this.dueDate,
        order: order ?? this.order,
        notes: this.notes,
      );

  bool get isDue {
    if (dueDate == null || isDone) {
      return false;
    }

    return dueDate.dateTime.isBefore(DateTime.now()) ? true : false;
  }

  bool isPinnedOrUpcoming(DateTime lookAheadDate) {
    if (isDone) {
      return false;
    }

    if (isPinned) {
      return true;
    }

    if (dueDate != null && dueDate.dateTime.isBefore(lookAheadDate)) {
      return true;
    }

    return false;
  }

  String toString() => "Task = {id: '$id', title: '$title', isDone: '$isDone'}";
}

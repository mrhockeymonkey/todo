import 'package:todo/providers/db_item.dart';

import '../date.dart';
import 'priority.dart';

class Task implements DbItem {
  @override
  final String? id;
  final String title;
  final String? categoryId;
  final bool isDone;
  final bool isFlagged;
  final Date? dueDate;
  final int order;
  final String notes;
  final Priority priority;

  const Task({
    this.id,
    required this.title,
    this.categoryId,
    this.isDone = false,
    this.isFlagged = false,
    this.dueDate,
    this.order = 0,
    this.notes = "",
    this.priority = Priority.notImportant,
  });

  factory Task.fromJson(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    categoryId: map['categoryId'],
    isDone: map['isDone'] ?? false,
    isFlagged: map['isFlagged'] ?? false,
    dueDate:
        map['dueDate'] != null
            ? Date.fromMillisecondsSinceEpoch(map['dueDate'])
            : null,
    order: map['order'] ?? 0,
    notes: map['notes'] ?? "",
    priority: Priority.fromJson(map['priority']),
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'categoryId': categoryId,
    'isDone': isDone,
    'isFlagged': isFlagged,
    'dueDate': dueDate?.millisecondsSinceEpoch,
    'order': order,
    'notes': notes,
    'priority': priority.name,
  };

  Task copyWith({
    String? title,
    bool? isDone,
    int? order,
    Date? dueDate,
    bool? isFlagged,
    Priority? priority,
  }) => Task(
    id: id,
    title: title ?? this.title,
    categoryId: categoryId,
    isDone: isDone ?? this.isDone,
    isFlagged: isFlagged ?? this.isFlagged,
    dueDate: dueDate ?? this.dueDate,
    order: order ?? this.order,
    notes: notes,
    priority: priority ?? this.priority,
  );

  bool get isDue {
    if (dueDate == null || isDone) {
      return false;
    }

    return dueDate!.dateTime.isBefore(DateTime.now()) ? true : false;
  }

  bool get isScheduled => dueDate != null;

  Task done() => copyWith(isDone: true, dueDate: Date.now());

  @override
  String toString() => "Task = {id: '$id', title: '$title', isDone: '$isDone'}";
}

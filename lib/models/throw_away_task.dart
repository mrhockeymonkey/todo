import 'package:todo/providers/db_item.dart';

import '../date.dart';

class ThrowAwayTask implements DbItem {
  @override
  final String? id;
  final String title;
  final bool isDone;
  final Date date;
  final int order;
  final bool isFlagged;
  final String? taskId;
  final String? routineId;

  const ThrowAwayTask({
    required this.id,
    required this.title,
    required this.isDone,
    required this.date,
    this.order = 0,
    this.isFlagged = false,
    this.taskId,
    this.routineId,
  });

  factory ThrowAwayTask.fromJson(Map<String, dynamic> map) => ThrowAwayTask(
        id: map['id'],
        title: map['title'],
        isDone: map['done'],
        date: Date.fromMillisecondsSinceEpoch(map['date']),
        order: map['order'] ?? 0,
        isFlagged: map['isFlagged'] ?? false,
        taskId: map['taskId'],
        routineId: map['routineId'],
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': isDone,
        'date': date.millisecondsSinceEpoch,
        'order': order,
        'isFlagged': isFlagged,
        'taskId': taskId,
        'routineId': routineId,
      };

  ThrowAwayTask copyWith({
    String? title,
    bool? isDone,
    Date? date,
    int? order,
    bool? isFlagged,
  }) =>
      ThrowAwayTask(
          id: id,
          title: title ?? this.title,
          isDone: isDone ?? this.isDone,
          date: date ?? this.date,
          order: order ?? this.order,
          isFlagged: isFlagged ?? this.isFlagged,
          taskId: taskId,
          routineId: routineId);

  ThrowAwayTask done() {
    return copyWith(isDone: true);
  }

  ThrowAwayTask tomorrow() {
    var tomorrow = date.add(const Duration(days: 1));
    return copyWith(date: tomorrow);
  }
}

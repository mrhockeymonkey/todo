import 'package:todo/providers/db_item.dart';

import '../date.dart';

class ThrowAwayTask implements DbItem {
  @override
  final String? id;
  final String title;
  final bool done;
  final Date date;
  final int order;
  final bool isFlagged;

  const ThrowAwayTask({
    required this.id,
    required this.title,
    required this.done,
    required this.date,
    this.order = 0,
    this.isFlagged = false,
  });

  factory ThrowAwayTask.fromJson(Map<String, dynamic> map) => ThrowAwayTask(
        id: map['id'],
        title: map['title'],
        done: map['done'],
        date: Date.fromMillisecondsSinceEpoch(map['date']),
        order: map['order'] ?? 0,
        isFlagged: map['isFlagged'] ?? false,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'date': date.millisecondsSinceEpoch,
        'order': order,
        'isFlagged': isFlagged,
      };

  ThrowAwayTask copyWith({
    String? title,
    bool? done,
    Date? date,
    int? order,
    bool? isFlagged,
  }) =>
      ThrowAwayTask(
        id: id,
        title: title ?? this.title,
        done: done ?? this.done,
        date: date ?? this.date,
        order: order ?? this.order,
        isFlagged: isFlagged ?? this.isFlagged,
      );

  ThrowAwayTask donee() {
    return copyWith(done: true);
  }

  ThrowAwayTask tomorrow() {
    var tomorrow = date.add(const Duration(days: 1));
    return copyWith(date: tomorrow);
  }
}

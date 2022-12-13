import 'package:todo/providers/db_item.dart';

import '../date.dart';

class ThrowAwayTask implements DbItem {
  @override
  final String? id;
  final String title;
  final bool done;
  final Date date;
  final int order;

  const ThrowAwayTask({
    required this.id,
    required this.title,
    required this.done,
    required this.date,
    this.order = 0,
  });

  factory ThrowAwayTask.fromMap(Map<String, dynamic> map) => ThrowAwayTask(
      id: map['id'],
      title: map['title'],
      done: map['done'],
      date: Date.fromMillisecondsSinceEpoch(map['date']),
      order: map['order'] ?? 0);

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'done': done,
        'date': date.millisecondsSinceEpoch,
        'order': order,
      };

  ThrowAwayTask copyWith({
    String? title,
    bool? done,
    Date? date,
    int? order,
  }) =>
      ThrowAwayTask(
        id: id,
        title: title ?? this.title,
        done: done ?? this.done,
        date: date ?? this.date,
        order: order ?? this.order,
      );

  ThrowAwayTask donee() {
    return copyWith(done: true);
  }

  ThrowAwayTask tomorrow() {
    var tomorrow = date.add(const Duration(days: 1));
    return copyWith(date: tomorrow);
  }
}

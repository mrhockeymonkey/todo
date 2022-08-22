import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import "package:flutter/foundation.dart";
import 'package:todo/providers/db_item.dart';

class ThrowAwayTask extends DbItem {
  final String id;
  final String title;
  final bool done;

  ThrowAwayTask({
    @required this.id,
    @required this.title,
    @required this.done,
  });

  factory ThrowAwayTask.fromMap(Map<String, dynamic> map) =>
      ThrowAwayTask(id: map['id'], title: map['title'], done: map['done']);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'done': done,
      };
}

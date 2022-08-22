import 'package:flutter/foundation.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models/throw_away_task.dart';

import '../date.dart';
import '../providers/db_item.dart';
import './throw_away_task.dart';

class DayPlan extends DbItem {
  DateTime date;
  String id;
  String title;
  List<String> backlogTaskIds;
  List<ThrowAwayTask> throwAwayTasks;

  DayPlan({
    @required this.date,
  }) {
    id = this.date.toIso8601String();
    title = this.date.toIso8601String();
    backlogTaskIds = [];
    throwAwayTasks = [
      new ThrowAwayTask(title: "Up", done: false),
      new ThrowAwayTask(title: "Do X", done: false),
      new ThrowAwayTask(title: "Do Y", done: false),
    ];
  }

  // DayPlan({
  //   @required this.date,
  //   @required this.id,
  //   @required this.title,
  //   @required this.backlogTaskIds,
  //   @required this.throwAwayTasks,
  // });

  DayPlan.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    date = map['date'];
    title = map['title'];
    backlogTaskIds = map['backlogTaskIds'];
    throwAwayTasks = map['throwAwayTasks'];
  }

  // DayPlan._internal(
  //     this.id, this.date, this.title, this.backlogTaskIds, this.throwAwayTasks);

  // factory DayPlan.fromMap(Map<String, dynamic> map) => DayPlan._internal(
  //     map['id'],
  //     map['date'],
  //     map['title'],
  //     map['backlogTaskIds'],
  //     map['throwAwayTasks']);

  void addThrowAwayTask() =>
      throwAwayTasks.add(new ThrowAwayTask(title: "new", done: false));

  Map<String, dynamic> toMap() => {
        "id": id,
        "date": date.millisecondsSinceEpoch,
        "title": title,
      };
}

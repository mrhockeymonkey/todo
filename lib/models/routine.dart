import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localstore/localstore.dart';
import 'dart:math';

import 'package:todo/providers/db_item.dart';

class Routine extends DbItem {
  final String id;
  final String title;

  final int recurNum;
  final String recurLen;
  DateTime lastCompletedDate;
  DateTime nextDueDate;

  final Color color;
  String notes;
  bool displayOnPinned;
  // final double percent;

  Routine({
    @required this.id,
    @required this.title,
    this.recurNum = 5,
    this.recurLen = "minutes",
    this.lastCompletedDate,
    this.nextDueDate,
    this.color = Colors.black,
    this.notes,
    this.displayOnPinned = false,
  }) {
    done();
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      title: map['title'],
      recurNum: map['recurNum'],
      recurLen: map['recurLen'],
      lastCompletedDate:
          DateTime.fromMillisecondsSinceEpoch(map['lastCompletedDate'] ?? 0),
      nextDueDate: DateTime.fromMillisecondsSinceEpoch(map['nextDueDate'] ?? 0),
      notes: map['notes'] ?? "",
      displayOnPinned: map['displayOnPinned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'recurNum': recurNum,
      'recurLen': recurLen,
      'lastCompletedDate': lastCompletedDate != null
          ? lastCompletedDate.millisecondsSinceEpoch
          : 0,
      'nextDueDate':
          nextDueDate != null ? nextDueDate.millisecondsSinceEpoch : 0,
      'notes': this.notes,
      'displayOnPinned': this.displayOnPinned ?? false,
    };
  }

  double get percent {
    if (lastCompletedDate == null || nextDueDate == null) {
      return 1.0;
    }

    var elapsed = DateTime.now().difference(lastCompletedDate);
    var foo = nextDueDate.difference(lastCompletedDate);

    return min(1.0, (elapsed.inSeconds / foo.inSeconds));
  }

  bool get isDue => percent >= 1.0;

  String get dueWhen =>
      isDue ? "due" : Jiffy(nextDueDate).from(DateTime.now()).toString();

  void done() {
    var now = Jiffy();
    var next = now.clone();

    switch (recurLen) {
      case 'minutes':
        next.add(minutes: recurNum);
        break;
      case 'hours':
        next.add(hours: recurNum);
        break;
      case 'days':
        next.add(days: recurNum);
        break;
      case 'weeks':
        next.add(weeks: recurNum);
        break;
      case 'months':
        next.add(months: recurNum);
        break;
      default: // minutes
        next.add(minutes: recurNum);
    }
    lastCompletedDate = now.dateTime;
    nextDueDate = next.dateTime;
    print(
        "Routine: '$title', Completed: '${lastCompletedDate.toIso8601String()}', NextDue: '${nextDueDate.toIso8601String()}'");
  }
}

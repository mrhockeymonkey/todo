import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:todo/date.dart';
import 'dart:math';

import 'package:todo/providers/db_item.dart';

class Routine extends DbItem {
  final String id;
  final String title;

  final int recurNum;
  final String recurLen;
  final DateTime lastCompletedDate;
  DateTime _nextDueDateTime;

  final Color color;
  final String notes;
  final bool displayOnPinned;
  final int order;

  Routine({
    @required this.id,
    @required this.title,
    this.recurNum = 5,
    this.recurLen = "minutes",
    lastCompletedDate,
    nextDueDateTime,
    this.color = Colors.black,
    this.notes,
    this.displayOnPinned = false,
    this.order = 0,
  })  : this.lastCompletedDate = lastCompletedDate == null ||
                lastCompletedDate == DateTime.fromMillisecondsSinceEpoch(0)
            ? Jiffy().dateTime
            : lastCompletedDate,
        this._nextDueDateTime = nextDueDateTime == null ||
                nextDueDateTime == DateTime.fromMillisecondsSinceEpoch(0)
            ? calculateNextDueDate(Jiffy(), recurLen, recurNum).dateTime
            : nextDueDateTime;

  //        {
  //             if (_nextDueDateTime == null ||
  //   _nextDueDateTime == DateTime.fromMillisecondsSinceEpoch(0)) {
  // _nextDueDateTime = _calculateNextDueDate(Jiffy()).dateTime;
  //       }

  // Routine({
  //   @required this.id,
  //   @required this.title,
  //   this.recurNum = 5,
  //   this.recurLen = "minutes",
  //   this.lastCompletedDate,
  //   nextDueDateTime,
  //   this.color = Colors.black,
  //   this.notes,
  //   this.displayOnPinned = false,
  //   this.order = 0,
  // }) {
  //   if (lastCompletedDate == null ||
  //       lastCompletedDate == DateTime.fromMillisecondsSinceEpoch(0)) {
  //     lastCompletedDate = Jiffy().dateTime;
  //   }

  //   _nextDueDateTime = nextDueDateTime;
  //   if (_nextDueDateTime == null ||
  //       _nextDueDateTime == DateTime.fromMillisecondsSinceEpoch(0)) {
  //     _nextDueDateTime = _calculateNextDueDate(Jiffy()).dateTime;
  //   }
  // }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      title: map['title'],
      recurNum: map['recurNum'],
      recurLen: map['recurLen'],
      lastCompletedDate:
          DateTime.fromMillisecondsSinceEpoch(map['lastCompletedDate'] ?? 0),
      nextDueDateTime:
          DateTime.fromMillisecondsSinceEpoch(map['nextDueDate'] ?? 0),
      notes: map['notes'] ?? "",
      displayOnPinned: map['displayOnPinned'] ?? false,
      order: map['order'] ?? 0,
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
      'nextDueDate': _nextDueDateTime != null
          ? _nextDueDateTime.millisecondsSinceEpoch
          : 0,
      'notes': this.notes,
      'displayOnPinned': this.displayOnPinned ?? false,
      'order': this.order,
    };
  }

  Routine copyWith(
          {String title,
          int order,
          DateTime lastCompletedDate,
          DateTime nextDueDateTime}) =>
      Routine(
        id: this.id,
        title: title ?? this.title,
        recurNum: this.recurNum,
        recurLen: this.recurLen,
        lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
        nextDueDateTime: nextDueDateTime ?? this._nextDueDateTime,
        color: this.color,
        notes: this.notes,
        displayOnPinned: this.displayOnPinned,
        order: order ?? this.order,
      );

  Routine copyAsDone() {
    var now = Jiffy();
    var lastCompletedDate = now.dateTime;
    var nextDueDateTime =
        calculateNextDueDate(now, this.recurLen, this.recurNum).dateTime;
    print(
        "Routine: '$title', Completed: '${lastCompletedDate.toIso8601String()}', NextDue: '${_nextDueDateTime.toIso8601String()}'");

    return this.copyWith(
        lastCompletedDate: lastCompletedDate, nextDueDateTime: nextDueDateTime);
  }

  Date get dueDate => new Date(_nextDueDateTime);

  double get percent {
    if (lastCompletedDate == null || _nextDueDateTime == null) {
      return 1.0;
    }

    var elapsed = DateTime.now().difference(lastCompletedDate);
    var foo = _nextDueDateTime.difference(lastCompletedDate);

    return min(1.0, (elapsed.inSeconds / foo.inSeconds));
  }

  bool get isDue => percent >= 1.0;

  String get dueWhen =>
      isDue ? "due" : Jiffy(_nextDueDateTime).from(DateTime.now()).toString();

  static Jiffy calculateNextDueDate(
      Jiffy lastCompleted, String recurLen, int recurNum) {
    switch (recurLen) {
      case 'minutes':
        return lastCompleted.add(minutes: recurNum);
        break;
      case 'hours':
        return lastCompleted.add(hours: recurNum);
        break;
      case 'days':
        return lastCompleted.add(days: recurNum);
        break;
      case 'weeks':
        return lastCompleted.add(weeks: recurNum);
        break;
      case 'months':
        return lastCompleted.add(months: recurNum);
        break;
      default: // minutes
        return lastCompleted.add(minutes: recurNum);
    }
  }
}

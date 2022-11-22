import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:todo/date.dart';
import 'dart:math';

import 'package:todo/providers/db_item.dart';

class Routine implements DbItem {
  final String? id;
  final String title;

  final int recurNum;
  final String recurLen;
  final Date lastCompletedDate;
  Date _nextDueDateTime;

  final Color color;
  final String notes;
  final bool displayOnPinned;
  final int order;

  Routine({
    this.id,
    required this.title,
    this.recurNum = 5,
    this.recurLen = "minutes",
    Date? lastCompletedDate,
    Date? nextDueDateTime,
    this.color = Colors.black,
    this.notes = "",
    this.displayOnPinned = false,
    this.order = 0,
  })  : this.lastCompletedDate = lastCompletedDate == null ||
                lastCompletedDate == Date.fromMillisecondsSinceEpoch(0)
            ? Date.now()
            : lastCompletedDate,
        this._nextDueDateTime = nextDueDateTime == null ||
                nextDueDateTime == Date.fromMillisecondsSinceEpoch(0)
            ? calculateNextDueDate(Date.now(), recurLen, recurNum)
            : nextDueDateTime;

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      title: map['title'],
      recurNum: map['recurNum'],
      recurLen: map['recurLen'],
      lastCompletedDate:
          Date.fromMillisecondsSinceEpoch(map['lastCompletedDate'] ?? 0),
      nextDueDateTime: Date.fromMillisecondsSinceEpoch(map['nextDueDate'] ?? 0),
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
      'displayOnPinned': this.displayOnPinned,
      'order': this.order,
    };
  }

  Routine copyWith({
    String? title,
    int? order,
    Date? lastCompletedDate,
    Date? nextDueDateTime,
  }) =>
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

  Routine done() {
    Date now = Date.now();
    Date lastCompletedDate = now;
    Date nextDueDateTime =
        calculateNextDueDate(now, this.recurLen, this.recurNum);
    print(
        "Routine: '$title', Completed: '${lastCompletedDate}', NextDue: '${_nextDueDateTime}'");

    return this.copyWith(
        lastCompletedDate: lastCompletedDate, nextDueDateTime: nextDueDateTime);
  }

  Routine tomorrow() {
    var tomorrow = this.dueDate.add(const Duration(days: 1));
    return this.copyWith(nextDueDateTime: tomorrow);
  }

  Date get dueDate => _nextDueDateTime;

  double get percent {
    if (lastCompletedDate == null || _nextDueDateTime == null) {
      return 1.0;
    }

    var elapsed = DateTime.now().difference(lastCompletedDate.dateTime);
    var foo = _nextDueDateTime.dateTime.difference(lastCompletedDate.dateTime);

    return min(1.0, (elapsed.inSeconds / foo.inSeconds));
  }

  bool get isDue => percent >= 1.0;

  String get dueWhen => isDue
      ? "due"
      : Jiffy(_nextDueDateTime.dateTime).from(DateTime.now()).toString();

  static Date calculateNextDueDate(
      Date lastCompleted, String recurLen, int recurNum) {
    var jiffy = Jiffy(lastCompleted.dateTime);
    switch (recurLen) {
      case 'minutes':
        jiffy.add(minutes: recurNum);
        break;
      case 'hours':
        jiffy.add(hours: recurNum);
        break;
      case 'days':
        jiffy.add(days: recurNum);
        break;
      case 'weeks':
        jiffy.add(weeks: recurNum);
        break;
      case 'months':
        jiffy.add(months: recurNum);
        break;
      default: // minutes
        jiffy.add(minutes: recurNum);
        break;
    }

    return Date(jiffy.dateTime);
  }
}

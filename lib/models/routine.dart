import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:todo/date.dart';
import 'package:todo/models/repeat_schedule.dart';
import 'dart:math';

import 'package:todo/providers/db_item.dart';

class Routine implements DbItem {
  @override
  final String? id;
  final String title;
  final RepeatSchedule schedule;
  final Date lastCompletedDate;
  Date _nextDueDateTime;

  final Color color;
  final String notes;
  final bool displayOnPinned;
  final int order;
  final bool isFlagged;

  Routine({
    this.id,
    required this.title,
    required this.schedule,
    Date? lastCompletedDate,
    Date? nextDueDateTime,
    this.color = Colors.black,
    this.notes = "",
    this.displayOnPinned = false,
    this.order = 0,
    this.isFlagged = false,
  })  : lastCompletedDate = lastCompletedDate == null ||
                lastCompletedDate == Date.fromMillisecondsSinceEpoch(0)
            ? Date.now()
            : lastCompletedDate,
        _nextDueDateTime = nextDueDateTime == null ||
                nextDueDateTime == Date.fromMillisecondsSinceEpoch(0)
            ? schedule.calculateNextDueDate(Date.now())
            : nextDueDateTime;

  factory Routine.fromJson(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      title: map['title'],
      schedule: RepeatSchedule.fromJson(map['schedule']),
      lastCompletedDate:
          Date.fromMillisecondsSinceEpoch(map['lastCompletedDate'] ?? 0),
      nextDueDateTime: Date.fromMillisecondsSinceEpoch(map['nextDueDate'] ?? 0),
      notes: map['notes'] ?? "",
      displayOnPinned: map['displayOnPinned'] ?? false,
      order: map['order'] ?? 0,
      isFlagged: map['isFlagged'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'schedule': schedule.toJson(),
      'lastCompletedDate': lastCompletedDate.millisecondsSinceEpoch,
      'nextDueDate': _nextDueDateTime.millisecondsSinceEpoch,
      'notes': notes,
      'displayOnPinned': displayOnPinned,
      'order': order,
      'isFlagged': isFlagged,
    };
  }

  Routine copyWith({
    String? title,
    int? order,
    Date? lastCompletedDate,
    Date? nextDueDateTime,
    bool? isFlagged,
  }) =>
      Routine(
        id: id,
        title: title ?? this.title,
        schedule: this.schedule,
        lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
        nextDueDateTime: nextDueDateTime ?? _nextDueDateTime,
        color: color,
        notes: notes,
        displayOnPinned: displayOnPinned,
        order: order ?? this.order,
        isFlagged: isFlagged ?? this.isFlagged,
      );

  Routine done() {
    Date now = Date.now();
    Date lastCompletedDate = now;
    Date nextDueDateTime = schedule.calculateNextDueDate(now);
    debugPrint(
        "Routine: '$title', Completed: '${lastCompletedDate}', NextDue: '${_nextDueDateTime}'");

    return copyWith(
      lastCompletedDate: lastCompletedDate,
      nextDueDateTime: nextDueDateTime,
      isFlagged: false,
    );
  }

  Routine tomorrow() {
    var tomorrow = dueDate.add(const Duration(days: 1));
    return copyWith(nextDueDateTime: tomorrow);
  }

  Date get dueDate => _nextDueDateTime;

  double get percent {
    var elapsed = DateTime.now().difference(lastCompletedDate.dateTime);
    var total =
        _nextDueDateTime.dateTime.difference(lastCompletedDate.dateTime);

    return min(1.0, (elapsed.inSeconds / total.inSeconds));
  }

  bool get isDue => percent >= 1.0;

  String get dueWhen => isDue
      ? "due"
      : Jiffy.parseFromDateTime(_nextDueDateTime.dateTime).from(Jiffy.now()).toString();
}

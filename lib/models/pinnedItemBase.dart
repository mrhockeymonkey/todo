import 'package:flutter/material.dart';
import 'task.dart';

abstract class PinnedItemBase {
  final Task _task;
  int date;
  int order;
  final String _itemType;

  PinnedItemBase(
    this._task,
    this.date,
    this.order,
    this._itemType,
  );

  Task get task => _task;

  int get listOrder => (date * 100) + order;

  String get itemType => _itemType;

  //String get itemType => itemType;

  void updateTask();

  int getNextDate(int currentDate);

  int getNextOrder(int currentOrder);

  //Task getTask();

  Widget build(BuildContext context);

  @override
  String toString() => "PinnedItemBase";
}

import 'package:flutter/material.dart';
import 'task.dart';

abstract class PinnedItem {
  final Task task;
  int date;
  int order;

  PinnedItem({
    this.task,
    this.date,
    this.order,
  });

  int get listOrder => (date * 100) + order;

  void updateTask();

  Task getTask();

  Widget build(BuildContext context);
}

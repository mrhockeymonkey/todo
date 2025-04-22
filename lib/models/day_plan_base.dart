import 'package:flutter/material.dart';
import 'package:todo/models/throw_away_task.dart';

abstract class DayPlanBase {
  //final ThrowAwayTask item;

  DayPlanBase();

  Widget build(BuildContext context);

  int get order; //=> item.order;

  // TItem get item;

  // Type get itemtype;

  bool get isDone; //=> item.isDone;

  bool get isFlagged; //=> item.isFlagged;
}

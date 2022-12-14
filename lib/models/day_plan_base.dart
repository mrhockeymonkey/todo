import 'package:flutter/material.dart';

abstract class DayPlanBase<TItem> {
  Widget build(BuildContext context);

  int get order;

  TItem get item;

  Type get itemtype;

  bool get isDone;
}

import 'package:flutter/material.dart';

abstract class DayPlanBase {

  DayPlanBase();

  Widget build(BuildContext context);

  int get order; 

  bool get isDone; 

  bool get isFlagged; 

  /// Display order for a day plan: outstanding before done, then flagged
  /// before unflagged, then by [order] ascending.
  ///
  /// This must be a single comparator: `List.sort` is not stable, so chaining
  /// several sorts does not preserve the earlier orderings.
  static int compare(DayPlanBase a, DayPlanBase b) {
    if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
    if (a.isFlagged != b.isFlagged) return a.isFlagged ? -1 : 1;
    return a.order.compareTo(b.order);
  }
}

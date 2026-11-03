import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/models/day_plan_base.dart';

class _Item extends DayPlanBase {
  final String name;
  @override
  final bool isDone;
  @override
  final bool isFlagged;
  @override
  final int order;

  _Item(this.name, {this.isDone = false, this.isFlagged = false, this.order = 0});

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  final expected = [
    _Item('flagged-0', isFlagged: true, order: 0),
    _Item('flagged-3', isFlagged: true, order: 3),
    _Item('plain-1', order: 1),
    _Item('plain-2', order: 2),
    _Item('done-flagged-5', isDone: true, isFlagged: true, order: 5),
    _Item('done-4', isDone: true, order: 4),
    _Item('done-6', isDone: true, order: 6),
  ];
  final names = expected.map((i) => i.name).toList();

  test('outstanding before done, then flagged first, then by order', () {
    final items = [...expected]..sort(DayPlanBase.compare);
    expect(items.map((i) => i.name), names);
  });

  test('result does not depend on the starting order', () {
    for (final start in [
      expected.reversed.toList(),
      [...expected]..shuffle(),
      [...expected]..sort((a, b) => b.order.compareTo(a.order)),
    ]) {
      start.sort(DayPlanBase.compare);
      expect(start.map((i) => i.name), names);
    }
  });

  test('compare is antisymmetric', () {
    for (final a in expected) {
      for (final b in expected) {
        expect(DayPlanBase.compare(a, b).sign, -DayPlanBase.compare(b, a).sign,
            reason: '${a.name} vs ${b.name}');
      }
    }
  });
}

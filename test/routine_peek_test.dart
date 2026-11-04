import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo/date.dart';
import 'package:todo/models/repeat_schedule.dart';
import 'package:todo/models/routine.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/widgets/routine_peek.dart';

/// Keeps routines in memory instead of hitting Localstore.
class _FakeRoutineProvider extends RoutineProvider {
  _FakeRoutineProvider(List<Routine> routines) : super(tableName: "routines") {
    for (final r in routines) {
      itemsMap[r.id!] = r;
    }
  }

  @override
  Future addOrUpdate(Routine item, {bool notify = true}) async {
    itemsMap[item.id!] = item;
    if (notify) notifyListeners();
  }
}

/// Never completed, so due now.
Routine due(String id, int order) => Routine(
      id: id,
      title: id,
      order: order,
      schedule: RepeatSchedule(),
      lastCompletedDate: Date.fromMillisecondsSinceEpoch(0),
    );

/// Completed just now, so not due.
Routine notDue(String id, int order) => due(id, order).done();

void main() {
  Future<_FakeRoutineProvider> pump(
      WidgetTester tester, List<Routine> routines) async {
    final provider = _FakeRoutineProvider(routines);
    await tester.pumpWidget(
      ChangeNotifierProvider<RoutineProvider>.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: RoutinePeek())),
      ),
    );
    return provider;
  }

  double ringValue(WidgetTester tester) => tester
      .widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator))
      .value!;

  testWidgets('focuses the first due routine and summarises the rest',
      (tester) async {
    await pump(tester, [due('A', 0), due('B', 1), due('C', 2), notDue('D', 3)]);

    expect(find.text('A'), findsOneWidget);
    expect(find.text('+ 2 routines'), findsOneWidget);
    expect(ringValue(tester), 0.25);
    expect(find.text('25%'), findsOneWidget);
  });

  testWidgets('swap cycles the focus through due routines and wraps',
      (tester) async {
    await pump(tester, [due('A', 0), due('B', 1), notDue('C', 2)]);
    expect(find.text('+ 1 routine'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pump();
    expect(find.text('B'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.swap_horiz));
    await tester.pump();
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('check marks the focused routine done and moves on',
      (tester) async {
    final provider = await pump(tester, [due('A', 0), due('B', 1)]);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();

    expect(provider.getItemById('A').isDue, isFalse);
    expect(find.text('B'), findsOneWidget);
    expect(ringValue(tester), 0.5);
  });

  testWidgets('swiping marks the focused routine done but keeps the tile',
      (tester) async {
    final provider = await pump(tester, [due('A', 0), due('B', 1)]);

    await tester.drag(find.text('A'), const Offset(600, 0));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(provider.getItemById('A').isDue, isFalse);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('shows an all-done state when nothing is due', (tester) async {
    final provider = await pump(tester, [due('A', 0)]);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();

    expect(provider.getItemById('A').isDue, isFalse);
    expect(find.text('All routines done'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byIcon(Icons.swap_horiz), findsNothing);
    expect(ringValue(tester), 1.0);
  });
}

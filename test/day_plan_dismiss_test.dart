import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo/date.dart';
import 'package:todo/models/task.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/widgets/day_plan_list.dart';

/// Keeps tasks in memory instead of hitting Localstore.
class _FakeTaskProvider extends TaskProvider {
  _FakeTaskProvider(List<Task> tasks) : super(tableName: "tasks") {
    for (final t in tasks) {
      itemsMap[t.id!] = t;
    }
  }

  @override
  Future addOrUpdate(Task item, {bool notify = true}) async {
    itemsMap[item.id!] = item;
    if (notify) notifyListeners();
  }
}

void main() {
  // Task.done() moves the due date to today, so plan for today to keep the
  // dismissed task in the list.
  final today = Date.now();

  Future<_FakeTaskProvider> pump(WidgetTester tester, List<Task> tasks) async {
    final provider = _FakeTaskProvider(tasks);
    await tester.pumpWidget(
      ChangeNotifierProvider<TaskProvider>.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: CustomScrollView(slivers: [DayPlanList(date: today)]),
          ),
        ),
      ),
    );
    return provider;
  }

  Future<void> swipe(WidgetTester tester, String title) async {
    await tester.drag(find.text(title), const Offset(600, 0));
    await tester.pumpAndSettle();
  }

  // A key that stays the same after the task is saved makes Dismissible
  // throw "A dismissed Dismissible widget is still part of the tree" when
  // the task is rebuilt at the same position.
  testWidgets('swiping the only task marks it done and keeps it in the list',
      (tester) async {
    final provider =
        await pump(tester, [Task(id: 'a', title: 'Only', dueDate: today)]);

    await swipe(tester, 'Only');

    expect(tester.takeException(), isNull);
    expect(provider.getItemById('a').isDone, isTrue);
    expect(find.text('Only'), findsOneWidget);
  });

  testWidgets('swiping an already-done task does not throw', (tester) async {
    await pump(tester, [
      Task(id: 'a', title: 'Done already', dueDate: today, isDone: true),
    ]);

    await swipe(tester, 'Done already');

    expect(tester.takeException(), isNull);
    expect(find.text('Done already'), findsOneWidget);
  });

  testWidgets('a swiped task moves below the outstanding tasks',
      (tester) async {
    await pump(tester, [
      Task(id: 'a', title: 'First', dueDate: today, order: 0),
      Task(id: 'b', title: 'Second', dueDate: today, order: 1),
    ]);

    await swipe(tester, 'First');

    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.text('Second')).dy,
        lessThan(tester.getTopLeft(find.text('First')).dy));
  });
}

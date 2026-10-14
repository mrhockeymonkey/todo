import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo/date.dart';
import 'package:todo/models/task.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/widgets/new_day_plan_task.dart';

/// Records saved tasks in memory instead of hitting Localstore.
class _FakeTaskProvider extends TaskProvider {
  final List<Task> saved = [];

  _FakeTaskProvider() : super(tableName: "tasks");

  @override
  Future addOrUpdate(Task item, {bool notify = true}) async => saved.add(item);
}

void main() {
  final date = Date(DateTime(2026, 10, 14));

  Future<(_FakeTaskProvider, List<bool>)> pump(WidgetTester tester) async {
    final provider = _FakeTaskProvider();
    final closed = <bool>[];
    await tester.pumpWidget(
      ChangeNotifierProvider<TaskProvider>.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: NewDayPlanTask(date: date, onClose: () => closed.add(true)),
          ),
        ),
      ),
    );
    return (provider, closed);
  }

  testWidgets('submitting a title saves a regular task for that day', (
    tester,
  ) async {
    final (provider, closed) = await pump(tester);

    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(provider.saved, hasLength(1));
    expect(provider.saved.single.title, 'Buy milk');
    expect(provider.saved.single.dueDate, date);
    expect(provider.saved.single.isDone, isFalse);
    expect(closed, hasLength(1));
  });

  testWidgets('submitting an empty title saves nothing', (tester) async {
    final (provider, closed) = await pump(tester);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(provider.saved, isEmpty);
    expect(closed, hasLength(1));
  });
}

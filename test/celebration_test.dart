import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo/celebration/celebration_controller.dart';
import 'package:todo/celebration/celebration_effect.dart';
import 'package:todo/celebration/celebration_style.dart';
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
  final today = Date.now();

  Future<(_FakeTaskProvider, CelebrationController)> pump(
    WidgetTester tester,
    List<Task> tasks,
    CelebrationStyle style,
  ) async {
    final provider = _FakeTaskProvider(tasks);
    final controller = CelebrationController();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TaskProvider>.value(value: provider),
          ChangeNotifierProvider(
            create: (_) => CelebrationSettings(initial: style, persist: false),
          ),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CustomScrollView(slivers: [DayPlanList(date: today)]),
          ),
        ),
      ),
    );
    return (provider, controller);
  }

  /// Advances [ms] milliseconds a frame at a time, so chained animations
  /// (slide out, then resize) each get to run.
  Future<void> advance(WidgetTester tester, int ms) async {
    for (var elapsed = 0; elapsed < ms; elapsed += 16) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  /// Opacity of the nearest Opacity above [title].
  double opacityOf(WidgetTester tester, String title) =>
      tester
          .widget<Opacity>(
            find
                .ancestor(of: find.text(title), matching: find.byType(Opacity))
                .first,
          )
          .opacity;

  for (final style in CelebrationStyle.values) {
    testWidgets('swiping a task with the ${style.label} style', (tester) async {
      final (provider, controller) = await pump(tester, [
        Task(id: 'a', title: 'First', dueDate: today, order: 0),
        Task(id: 'b', title: 'Second', dueDate: today, order: 1),
      ], style);

      await tester.drag(find.text('First'), const Offset(600, 0));
      // The row slides off, then the celebration starts.
      await advance(tester, 250);

      final animates = style != CelebrationStyle.none;
      expect(
        find.byType(CelebrationOverlay),
        animates ? findsOneWidget : findsNothing,
      );

      // Let the row collapse and the done item appear in its new place.
      await advance(tester, 400);
      expect(provider.getItemById('a').isDone, isTrue);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(CelebrationOverlay), findsNothing);
      expect(controller.isHidden('a'), isFalse);
      expect(controller.isPlaying, isFalse);
      expect(opacityOf(tester, 'First'), 1);
      // Still re-sorted below the outstanding task.
      expect(
        tester.getTopLeft(find.text('Second')).dy,
        lessThan(tester.getTopLeft(find.text('First')).dy),
      );
    });
  }

  testWidgets('the done item stays hidden until the ribbon lands', (
    tester,
  ) async {
    final (_, controller) = await pump(tester, [
      Task(id: 'a', title: 'First', dueDate: today, order: 0),
      Task(id: 'b', title: 'Second', dueDate: today, order: 1),
    ], CelebrationStyle.ribbon);

    await tester.drag(find.text('First'), const Offset(600, 0));
    // The row slides off (~200ms, when the ribbon sets off) and collapses
    // (~300ms), then the done item is rebuilt; the ribbon lands 780ms after
    // it set off, so is still in flight.
    await advance(tester, 650);
    expect(controller.isHidden('a'), isTrue);
    expect(find.text('First'), findsOneWidget);
    expect(opacityOf(tester, 'First'), 0);
    expect(controller.targetRect('a'), isNotNull);

    await advance(tester, 400);
    expect(controller.isHidden('a'), isFalse);
    expect(opacityOf(tester, 'First'), 1);

    await tester.pumpAndSettle();
    expect(find.byType(CelebrationOverlay), findsNothing);
  });

  testWidgets('swiping an already-done task does not celebrate', (
    tester,
  ) async {
    await pump(tester, [
      Task(id: 'a', title: 'Done already', dueDate: today, isDone: true),
    ], CelebrationStyle.ribbon);

    await tester.drag(find.text('Done already'), const Offset(600, 0));
    await advance(tester, 250);
    expect(find.byType(CelebrationOverlay), findsNothing);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo/celebration/celebration_controller.dart';
import 'package:todo/celebration/celebration_effect.dart';
import 'package:todo/celebration/celebration_screen.dart';
import 'package:todo/celebration/celebration_style.dart';
import 'package:todo/celebration/effects/circuit_effect.dart';
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

  group('circuit route', () {
    Offset endOf(Path p) {
      final m = p.computeMetrics().last;
      return m.getTangentForOffset(m.length)!.position;
    }

    test(
      'starts at the tile, loops up and over, and drops to the done item',
      () {
        final route = circuitRoute(
          start: const Offset(380, 300),
          endY: 500,
          width: 400,
          top: 100,
          radius: 36,
        );
        final bounds = route.getBounds();
        expect(
          route.computeMetrics().first.getTangentForOffset(0)!.position,
          const Offset(380, 300),
        );
        expect(endOf(route).dx, closeTo(200, 0.01));
        expect(endOf(route).dy, closeTo(500, 0.01));
        // The loop rises a full diameter above the row, left of the middle.
        expect(bounds.top, closeTo(300 - 72, 0.5));
        expect(bounds.left, closeTo(200 - 72, 0.5));
      },
    );

    test('loops downwards when the done item is above', () {
      final route = circuitRoute(
        start: const Offset(380, 300),
        endY: 150,
        width: 400,
        top: 100,
        radius: 36,
      );
      expect(endOf(route).dy, closeTo(150, 0.01));
      expect(route.getBounds().bottom, closeTo(300 + 72, 0.5));
    });

    test('shrinks the loop to stay below the app bar', () {
      final route = circuitRoute(
        start: const Offset(380, 140),
        endY: 400,
        width: 400,
        top: 100,
        radius: 36,
      );
      expect(route.getBounds().top, greaterThanOrEqualTo(100 - 0.5));
    });
  });

  testWidgets('circuit sliders change thickness and speed', (tester) async {
    final settings = CelebrationSettings(persist: false);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: const MaterialApp(home: CelebrationScreen()),
      ),
    );

    expect(find.text('4.0 px'), findsOneWidget);
    expect(find.text('900 px/s'), findsOneWidget);

    final sliders = find.byType(Slider);
    await tester.drag(sliders.at(0), const Offset(-1000, 0));
    await tester.drag(sliders.at(1), const Offset(1000, 0));
    await tester.pump();

    expect(settings.circuit.thickness, CircuitOptions.minThickness);
    expect(settings.circuit.speed, CircuitOptions.maxSpeed);

    await tester.tap(find.text('Reset to defaults'));
    await tester.pump();
    expect(settings.circuit.thickness, 4);
    expect(settings.circuit.speed, 900);
  });
}

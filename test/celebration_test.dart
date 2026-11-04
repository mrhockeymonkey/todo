import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo/celebration/celebration_controller.dart';
import 'package:todo/celebration/celebration_screen.dart';
import 'package:todo/celebration/circuit_animation.dart';
import 'package:todo/celebration/circuit_settings.dart';
import 'package:todo/date.dart';
import 'package:todo/models/priority.dart';
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
  ) async {
    final provider = _FakeTaskProvider(tasks);
    final controller = CelebrationController();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TaskProvider>.value(value: provider),
          ChangeNotifierProvider(
            create: (_) => CircuitSettings(persist: false),
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

  List<Task> twoTasks() => [
    Task(
      id: 'a',
      title: 'First',
      dueDate: today,
      order: 0,
      priority: Priority.urgent,
    ),
    Task(id: 'b', title: 'Second', dueDate: today, order: 1),
  ];

  testWidgets('swiping a task plays the animation in its priority colour', (
    tester,
  ) async {
    final (provider, controller) = await pump(tester, twoTasks());

    await tester.drag(find.text('First'), const Offset(600, 0));
    // The row slides off, then the animation starts.
    await advance(tester, 250);
    final animation = tester.widget<CircuitAnimation>(
      find.byType(CircuitAnimation),
    );
    expect(animation.request.colour, Priority.urgent.color);
    expect(animation.request.taskId, 'a');

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(provider.getItemById('a').isDone, isTrue);
    expect(find.byType(CircuitAnimation), findsNothing);
    expect(controller.isPlaying, isFalse);
    expect(controller.isHidden('a'), isFalse);
    expect(opacityOf(tester, 'First'), 1);
    // Still re-sorted below the outstanding task.
    expect(
      tester.getTopLeft(find.text('Second')).dy,
      lessThan(tester.getTopLeft(find.text('First')).dy),
    );
  });

  testWidgets('the done item stays hidden until the line reaches it', (
    tester,
  ) async {
    final (_, controller) = await pump(tester, twoTasks());

    await tester.drag(find.text('First'), const Offset(600, 0));
    await advance(tester, 250);
    expect(controller.isHidden('a'), isTrue);

    // Step until it's revealed: by then the done item was laid out (hidden)
    // and the animation is still running its tail in.
    var sawHiddenDoneItem = false;
    for (var i = 0; i < 300 && controller.isHidden('a'); i++) {
      if (controller.targetRect('a') != null) {
        sawHiddenDoneItem = true;
        expect(opacityOf(tester, 'First'), 0);
      }
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(sawHiddenDoneItem, isTrue);
    expect(controller.isHidden('a'), isFalse);
    expect(opacityOf(tester, 'First'), 1);
    expect(find.byType(CircuitAnimation), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircuitAnimation), findsNothing);
  });

  testWidgets('swiping an already-done task does not animate', (tester) async {
    await pump(tester, [
      Task(id: 'a', title: 'Done already', dueDate: today, isDone: true),
    ]);

    await tester.drag(find.text('Done already'), const Offset(600, 0));
    await advance(tester, 250);
    expect(find.byType(CircuitAnimation), findsNothing);

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
    final settings = CircuitSettings(persist: false);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: const MaterialApp(home: CelebrationScreen()),
      ),
    );

    expect(find.text('16.0 px'), findsWidgets);
    expect(find.text('1200 px/s'), findsOneWidget);

    final sliders = find.byType(Slider);
    await tester.drag(sliders.at(0), const Offset(-1000, 0));
    await tester.drag(sliders.at(1), const Offset(1000, 0));
    await tester.pump();

    expect(settings.options.thickness, CircuitParam.thickness.min);
    expect(settings.options.speed, CircuitParam.speed.max);

    await tester.tap(find.text('Reset to defaults'));
    await tester.pump();
    expect(settings.options.thickness, 16);
    expect(settings.options.speed, 1200);
  });

  group('circuit motion', () {
    // Start on the right at y=300, loop up to y=228, drop to y=600.
    final route = circuitRoute(
      start: const Offset(380, 300),
      endY: 600,
      width: 400,
      top: 100,
      radius: 36,
    );

    /// Speed around [seconds], in px/s.
    double speedAt(CircuitMotion motion, double seconds) =>
        (motion.distanceAt(seconds + 0.005) -
            motion.distanceAt(seconds - 0.005)) /
        0.01;

    test('moves at a constant speed without gravity', () {
      final motion = CircuitMotion(
        route,
        CircuitOptions.of({CircuitParam.gravity: 0, CircuitParam.speed: 500}),
      );
      expect(motion.distanceAt(0.5), closeTo(250, 1));
      expect(speedAt(motion, 0.2), closeTo(500, 1));
    });

    test('slows climbing into the loop and speeds up on the drop', () {
      final motion = CircuitMotion(
        route,
        CircuitOptions.of({
          CircuitParam.gravity: 2500,
          CircuitParam.speed: 900,
          CircuitParam.minSpeed: 50,
        }),
      );
      final start = speedAt(motion, 0.02);

      // Find the times at the top of the loop and near the bottom.
      double timeAtDistance(double d) {
        var t = 0.0;
        while (motion.distanceAt(t) < d) {
          t += 0.001;
        }
        return t;
      }

      final loopTop = route.computeMetrics().first;
      var topDistance = 0.0, topY = double.infinity;
      for (var d = 0.0; d < loopTop.length; d += 1) {
        final y = loopTop.getTangentForOffset(d)!.position.dy;
        if (y < topY) {
          topY = y;
          topDistance = d;
        }
      }
      final top = speedAt(motion, timeAtDistance(topDistance));
      final bottom = speedAt(motion, timeAtDistance(motion.length - 10));

      expect(start, closeTo(900, 10));
      // v² = v0² + 2g·Δy: 72px up, then 300px below the start.
      expect(top, closeTo(sqrt(900 * 900 - 2 * 2500 * 72), 15));
      expect(bottom, closeTo(sqrt(900 * 900 + 2 * 2500 * 290), 25));
    });

    test('never drops below the minimum speed', () {
      final motion = CircuitMotion(
        route,
        CircuitOptions.of({
          CircuitParam.gravity: 8000,
          CircuitParam.speed: 200,
          CircuitParam.minSpeed: 150,
        }),
      );
      for (var t = 0.0; t < 1; t += 0.05) {
        expect(speedAt(motion, t + 0.01), greaterThanOrEqualTo(149));
      }
    });
  });
}

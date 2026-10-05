import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo/journey/journey_provider.dart';
import 'package:todo/journey/journey_screen.dart';

void main() {
  late JourneyProvider journey;

  Future<void> pumpJourney(WidgetTester tester) async {
    // A phone-sized screen so the whole journey fits without scrolling.
    tester.view.physicalSize = const Size(1200, 2700);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    journey = JourneyProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: journey,
        child: const MaterialApp(home: JourneyScreen()),
      ),
    );
  }

  // The current step pulses forever, so pumpAndSettle would never settle.
  Future<void> letAnimationsPlay(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  // The node sits just above its label.
  Offset nodeFor(WidgetTester tester, String name) =>
      tester.getCenter(find.text(name)) - const Offset(0, 48);

  Future<void> holdStep(WidgetTester tester, String name) async {
    final gesture = await tester.startGesture(nodeFor(tester, name));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1000));
    await gesture.up();
    await letAnimationsPlay(tester);
  }

  testWidgets('shows every step and starts on the first', (tester) async {
    await pumpJourney(tester);

    for (final step in JourneyProvider.steps) {
      expect(find.text(step.name), findsOneWidget);
    }
    expect(find.text("HOLD"), findsOneWidget);
    expect(journey.completed, 0);
  });

  testWidgets('steps sit in middle, right, middle, left lanes', (tester) async {
    await pumpJourney(tester);
    final xs = [
      for (final name in ["Noji", "Mauril", "Podcast", "Verbs", "Finish"])
        tester.getCenter(find.text(name)).dx,
    ];

    expect(xs[0], xs[2]);
    expect(xs[0], xs[4]);
    expect(xs[1] - xs[0], greaterThan(0));
    expect(xs[1] - xs[0], closeTo(xs[0] - xs[3], 0.01));
  });

  testWidgets('holding steps in order completes the journey', (tester) async {
    await pumpJourney(tester);

    for (var i = 0; i < JourneyProvider.steps.length; i++) {
      await holdStep(tester, JourneyProvider.steps[i].name);
      expect(journey.completed, i + 1);
    }

    expect(journey.isFinished, isTrue);
    expect(find.text("HOLD"), findsNothing);
  });

  testWidgets('a quick tap does not complete a step', (tester) async {
    await pumpJourney(tester);

    await tester.tapAt(nodeFor(tester, "Noji"));
    await letAnimationsPlay(tester);

    expect(journey.completed, 0);
  });

  testWidgets('locked steps cannot be skipped to', (tester) async {
    await pumpJourney(tester);

    await holdStep(tester, "Podcast");

    expect(journey.completed, 0);
  });

  testWidgets('reset returns to the first step', (tester) async {
    await pumpJourney(tester);
    await holdStep(tester, "Noji");
    expect(journey.completed, 1);

    await tester.tap(find.byTooltip("Reset journey"));
    await letAnimationsPlay(tester);

    expect(journey.completed, 0);
    expect(find.text("HOLD"), findsOneWidget);
  });
}

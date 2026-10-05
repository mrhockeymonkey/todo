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

  testWidgets('shows every step and starts on the first', (tester) async {
    await pumpJourney(tester);

    for (final step in JourneyProvider.steps) {
      expect(find.text(step.name), findsOneWidget);
    }
    expect(find.text("START"), findsOneWidget);
    expect(journey.completed, 0);
  });

  for (final effect in [
    JourneyEffect.burst,
    JourneyEffect.confetti,
    JourneyEffect.shockwave,
  ]) {
    testWidgets('tapping steps in order completes them (${effect.name})', (
      tester,
    ) async {
      await pumpJourney(tester);
      journey.effect = effect;

      for (var i = 0; i < JourneyProvider.steps.length; i++) {
        // Tap the node itself, which sits just above its label.
        await tester.tapAt(
          tester.getCenter(find.text(JourneyProvider.steps[i].name)) -
              const Offset(0, 50),
        );
        await letAnimationsPlay(tester);
        expect(journey.completed, i + 1);
      }

      expect(journey.isFinished, isTrue);
      expect(find.text("START"), findsNothing);
    });
  }

  testWidgets('locked steps cannot be skipped to', (tester) async {
    await pumpJourney(tester);

    await tester.tapAt(
      tester.getCenter(find.text("Podcast")) - const Offset(0, 50),
    );
    await letAnimationsPlay(tester);

    expect(journey.completed, 0);
  });

  testWidgets('hold mode needs a long press, not a tap', (tester) async {
    await pumpJourney(tester);
    journey.effect = JourneyEffect.hold;
    await tester.pump();
    final node = tester.getCenter(find.text("Noji")) - const Offset(0, 50);

    await tester.tapAt(node);
    await letAnimationsPlay(tester);
    expect(journey.completed, 0);

    final gesture = await tester.startGesture(node);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1000));
    await gesture.up();
    await letAnimationsPlay(tester);
    expect(journey.completed, 1);
  });

  testWidgets('reset returns to the first step', (tester) async {
    await pumpJourney(tester);
    await tester.tapAt(
      tester.getCenter(find.text("Noji")) - const Offset(0, 50),
    );
    await letAnimationsPlay(tester);
    expect(journey.completed, 1);

    await tester.tap(find.byTooltip("Reset journey"));
    await letAnimationsPlay(tester);

    expect(journey.completed, 0);
    expect(find.text("START"), findsOneWidget);
  });
}

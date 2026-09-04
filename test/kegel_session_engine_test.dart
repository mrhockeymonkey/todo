import 'package:flutter_test/flutter_test.dart';
import 'package:todo/tools/kegels/kegel_pattern.dart';
import 'package:todo/tools/kegels/kegel_session_engine.dart';

/// Pumps just past [seconds] so the current step's controller completes
/// (a frame must land beyond the duration for the completed status to fire).
Future<void> pumpStep(WidgetTester tester, double seconds) => tester
    .pump(Duration(milliseconds: (seconds * 1000).round() + 50));

void main() {
  test('preset totals match the training list durations', () {
    expect(kKegelTraining[0].totalDuration, const Duration(seconds: 18));
    expect(kKegelTraining[1].totalDuration, const Duration(seconds: 64));
    expect(kKegelTraining[2].totalDuration, const Duration(seconds: 36));
    expect(kKegelTraining[3].totalDuration, const Duration(seconds: 40));
    expect(kKegelTraining[4].totalDuration, const Duration(seconds: 22));
    expect(kKegelTraining[5].totalDuration, const Duration(seconds: 64));
    expect(kKegelTraining[6].totalDuration, const Duration(seconds: 24));
  });

  testWidgets('engine runs get ready, reps, rest and completes',
      (tester) async {
    const patterns = [
      KegelPattern(
        name: "A",
        description: "",
        contractSeconds: 1,
        holdSeconds: 1,
        relaxSeconds: 1,
        waitSeconds: 0, // zero-duration steps must be skipped
        reps: 2,
      ),
      KegelPattern(
        name: "B",
        description: "",
        contractSeconds: 1,
        holdSeconds: 0,
        relaxSeconds: 1,
        waitSeconds: 0,
        reps: 1,
      ),
    ];
    final engine = KegelSessionEngine(vsync: tester, patterns: patterns);

    engine.start();
    expect(engine.phase, KegelPhase.getReady);
    expect(engine.countdownSeconds, kGetReadySeconds.ceil());
    expect(engine.fill, 0);
    await tester.pump(); // anchor the ticker

    await pumpStep(tester, kGetReadySeconds);
    expect(engine.phase, KegelPhase.contract);
    expect(engine.currentExerciseIndex, 0);
    // Exercise A: 2 reps x (1 + 1 + 1) seconds.
    expect(engine.countdownSeconds, 6);

    await pumpStep(tester, 1);
    expect(engine.phase, KegelPhase.hold);
    expect(engine.fill, 1);

    await pumpStep(tester, 1);
    expect(engine.phase, KegelPhase.relax);

    // Wait is zero so the second rep's contract comes next.
    await pumpStep(tester, 1);
    expect(engine.phase, KegelPhase.contract);
    expect(engine.countdownSeconds, 3);

    // Finish rep 2 -> rest before exercise B.
    await pumpStep(tester, 1);
    await pumpStep(tester, 1);
    await pumpStep(tester, 1);
    expect(engine.phase, KegelPhase.rest);
    expect(engine.currentExerciseIndex, 1);
    expect(engine.countdownSeconds, kRestSeconds.ceil());

    await pumpStep(tester, kRestSeconds);
    expect(engine.phase, KegelPhase.contract);
    expect(engine.currentExerciseIndex, 1);

    // Hold is zero: contract goes straight to relax.
    await pumpStep(tester, 1);
    expect(engine.phase, KegelPhase.relax);

    await pumpStep(tester, 1);
    expect(engine.isComplete, true);

    engine.dispose();
  });

  testWidgets('pause freezes progress and resume continues', (tester) async {
    const patterns = [
      KegelPattern(
        name: "A",
        description: "",
        contractSeconds: 2,
        holdSeconds: 0,
        relaxSeconds: 2,
        waitSeconds: 0,
        reps: 1,
      ),
    ];
    final engine = KegelSessionEngine(vsync: tester, patterns: patterns);

    engine.start();
    await tester.pump(); // anchor the ticker
    await pumpStep(tester, kGetReadySeconds);
    expect(engine.phase, KegelPhase.contract);

    await tester.pump(const Duration(seconds: 1)); // halfway into contract
    final fillAtPause = engine.fill;
    expect(fillAtPause, greaterThan(0));

    engine.pause();
    await tester.pump(const Duration(seconds: 5));
    expect(engine.fill, fillAtPause);
    expect(engine.phase, KegelPhase.contract);

    engine.resume();
    await tester.pump(); // re-anchor the ticker
    await pumpStep(tester, 1); // remaining contract time
    expect(engine.phase, KegelPhase.relax); // hold is zero, so straight on
    expect(engine.fill, 1);

    engine.dispose();
  });

  testWidgets('next and previous move one stage at a time incl. rests',
      (tester) async {
    const pattern = KegelPattern(
      name: "A",
      description: "",
      contractSeconds: 2,
      holdSeconds: 2,
      relaxSeconds: 2,
      waitSeconds: 0,
      reps: 2,
    );
    // Two exercises => stages [ex0 (0), rest (1), ex1 (2)].
    final engine =
        KegelSessionEngine(vsync: tester, patterns: const [pattern, pattern]);

    engine.start();
    await tester.pump(); // anchor the ticker
    await pumpStep(tester, kGetReadySeconds);
    expect(engine.currentStageIndex, 0);
    expect(engine.phase, KegelPhase.contract);

    // Next from an exercise lands on the rest stage, not the next exercise.
    engine.skipToNextStage();
    await tester.pump(const Duration(milliseconds: 100));
    expect(engine.currentStageIndex, 1);
    expect(engine.phase, KegelPhase.rest);

    // Next from the rest lands on the exercise it precedes.
    engine.skipToNextStage();
    await tester.pump(const Duration(milliseconds: 100));
    expect(engine.currentStageIndex, 2);
    expect(engine.phase, KegelPhase.contract);

    // Just entered exercise 1 -> previous steps back to the rest stage.
    engine.skipToPreviousStage();
    await tester.pump(const Duration(milliseconds: 100));
    expect(engine.currentStageIndex, 1);
    expect(engine.phase, KegelPhase.rest);

    // Back into exercise 1 and well into it -> previous restarts the stage.
    engine.skipToNextStage();
    await tester.pump(const Duration(milliseconds: 100));
    await pumpStep(tester, 2); // into the hold step
    expect(engine.phase, KegelPhase.hold);
    engine.skipToPreviousStage();
    await tester.pump(const Duration(milliseconds: 100));
    expect(engine.currentStageIndex, 2);
    expect(engine.phase, KegelPhase.contract);

    // Skipping past the last stage completes the session.
    engine.skipToNextStage();
    await tester.pump(const Duration(milliseconds: 100));
    expect(engine.isComplete, true);

    engine.dispose();
  });
}

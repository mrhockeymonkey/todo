/// Seconds of "Get ready" countdown before the first exercise.
const double kGetReadySeconds = 3;

/// Seconds of rest between exercises in a training session.
const double kRestSeconds = 15;

/// A single kegel exercise pattern.
///
/// One rep is: contract (circle fills) -> hold (stays full) ->
/// relax (circle empties) -> wait (stays empty). A pattern is [reps]
/// repetitions of that cycle. All values are tweakable; the total
/// duration is `reps * (contract + hold + relax + wait)` — the trailing
/// wait is included and blends into the rest period that follows.
class KegelPattern {
  final String name;
  final String description;
  final double contractSeconds;
  final double holdSeconds;
  final double relaxSeconds;
  final double waitSeconds;
  final int reps;

  const KegelPattern({
    required this.name,
    required this.description,
    required this.contractSeconds,
    required this.holdSeconds,
    required this.relaxSeconds,
    required this.waitSeconds,
    required this.reps,
  });

  double get repSeconds =>
      contractSeconds + holdSeconds + relaxSeconds + waitSeconds;

  Duration get totalDuration =>
      Duration(milliseconds: (reps * repSeconds * 1000).round());
}

const KegelPattern _calmWave = KegelPattern(
  name: "Calm Wave",
  description: "Slow, even waves. Contract, hold and release over "
      "four seconds each, then rest before the next wave.",
  contractSeconds: 3.2,
  holdSeconds: 3,
  relaxSeconds: 0.5,
  waitSeconds: 1.5,
  reps: 8,
);

/// The training session: exercises run in order with a rest between each.
const List<KegelPattern> kKegelTraining = [
  KegelPattern(
    name: "Gentle Pulses",
    description: "Quick, light squeezes to warm up. "
        "Contract for a second, then release.",
    contractSeconds: .5,
    holdSeconds: .7,
    relaxSeconds: .7,
    waitSeconds: .5,
    reps: 10,
  ),
  _calmWave,
  KegelPattern(
    name: "Soft Beats",
    description: "A steady rhythm of short squeezes with a brief hold.",
    contractSeconds: 1,
    holdSeconds: 2,
    relaxSeconds: 0.5,
    waitSeconds: 1,
    reps: 10,
  ),
  KegelPattern(
    name: "Core Beat",
    description: "Continuous medium-paced beats with no pause "
        "between reps.",
    contractSeconds: .3,
    holdSeconds: 1.9,
    relaxSeconds: .3,
    waitSeconds: 2,
    reps: 8,
  ),
  KegelPattern(
    name: "Front Hold", // TODO
    description: "Squeeze and hold at full strength, focusing on the "
        "front muscles, then release quickly.",
    contractSeconds: 2,
    holdSeconds: 8,
    relaxSeconds: 1,
    waitSeconds: 0,
    reps: 2,
  ),
  _calmWave,
  KegelPattern(
    name: "Endurance Squeeze", // TODO
    description: "A long, sustained hold to build endurance. "
        "Release slowly and with control.",
    contractSeconds: 2,
    holdSeconds: 8,
    relaxSeconds: 2,
    waitSeconds: 0,
    reps: 2,
  ),
];

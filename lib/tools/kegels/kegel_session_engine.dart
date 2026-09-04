import 'package:flutter/material.dart';
import 'package:todo/tools/kegels/kegel_pattern.dart';

enum KegelPhase { getReady, contract, hold, relax, wait, rest, complete }

class SessionStep {
  final KegelPhase phase;
  final double seconds;
  final double fillFrom;
  final double fillTo;

  /// Index into the pattern list; -1 for getReady/complete.
  /// Rest steps carry the index of the *upcoming* exercise.
  final int exerciseIndex;

  const SessionStep({
    required this.phase,
    required this.seconds,
    this.fillFrom = 0,
    this.fillTo = 0,
    this.exerciseIndex = -1,
  });
}

/// Drives a training session as a flat queue of timed steps, animating the
/// circle fill with a single re-targeted [AnimationController].
///
/// Notifies listeners on step/phase changes and pause/resume; listen to
/// [frameListenable] for per-frame values ([fill], [countdownSeconds]).
class KegelSessionEngine extends ChangeNotifier {
  final List<KegelPattern> patterns;
  final List<SessionStep> _steps = [];

  /// First step index of each stage (an exercise or a rest), in queue order:
  /// [exercise0, rest, exercise1, rest, ...]. Used for prev/next skipping;
  /// stage index equals the queue chip index by construction.
  final List<int> _stageFirstStep = [];

  /// Seconds remaining in the current exercise at the start of each step.
  late final List<double> _remainingAtStep;

  late final AnimationController _controller;
  late Animation<double> _fill;
  int _stepIndex = 0;
  bool _isPaused = false;
  bool _disposed = false;

  KegelSessionEngine({
    required TickerProvider vsync,
    required this.patterns,
  }) {
    _buildSteps();
    _controller = AnimationController(vsync: vsync);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _advance();
    });
    _fill = _controller;
  }

  void _buildSteps() {
    _steps.add(const SessionStep(
        phase: KegelPhase.getReady, seconds: kGetReadySeconds));

    for (var i = 0; i < patterns.length; i++) {
      final pattern = patterns[i];
      if (i > 0) {
        _stageFirstStep.add(_steps.length);
        _steps.add(SessionStep(
            phase: KegelPhase.rest, seconds: kRestSeconds, exerciseIndex: i));
      }
      _stageFirstStep.add(_steps.length);
      for (var rep = 0; rep < pattern.reps; rep++) {
        _steps.addAll([
          SessionStep(
              phase: KegelPhase.contract,
              seconds: pattern.contractSeconds,
              fillFrom: 0,
              fillTo: 1,
              exerciseIndex: i),
          SessionStep(
              phase: KegelPhase.hold,
              seconds: pattern.holdSeconds,
              fillFrom: 1,
              fillTo: 1,
              exerciseIndex: i),
          SessionStep(
              phase: KegelPhase.relax,
              seconds: pattern.relaxSeconds,
              fillFrom: 1,
              fillTo: 0,
              exerciseIndex: i),
          SessionStep(
              phase: KegelPhase.wait,
              seconds: pattern.waitSeconds,
              exerciseIndex: i),
        ].where((step) => step.seconds > 0));
      }
    }
    _steps.add(const SessionStep(phase: KegelPhase.complete, seconds: 0));

    // Suffix sums of step durations, reset at each exercise/rest boundary,
    // so the countdown shows time left in the current context.
    _remainingAtStep = List.filled(_steps.length, 0);
    var remaining = 0.0;
    for (var i = _steps.length - 1; i >= 0; i--) {
      final step = _steps[i];
      final isExerciseStep = step.phase != KegelPhase.getReady &&
          step.phase != KegelPhase.rest &&
          step.phase != KegelPhase.complete;
      if (!isExerciseStep) {
        _remainingAtStep[i] = step.seconds;
        remaining = 0;
      } else {
        remaining += step.seconds;
        _remainingAtStep[i] = remaining;
      }
    }
  }

  // --- Public surface ---

  /// Ticks every animation frame; use for [fill] and [countdownSeconds].
  Listenable get frameListenable => _controller;

  double get fill => _fill.value;

  SessionStep get _currentStep => _steps[_stepIndex];

  KegelPhase get phase => _currentStep.phase;

  bool get isPaused => _isPaused;

  bool get isComplete => phase == KegelPhase.complete;

  int get currentStepIndex => _stepIndex;

  int get currentExerciseIndex => _currentStep.exerciseIndex;

  /// The index of the current stage (exercise or rest), which equals the
  /// queue chip index. getReady maps to 0 (the first exercise); complete
  /// maps to the last stage.
  int get currentStageIndex {
    var stage = 0;
    for (var s = 0; s < _stageFirstStep.length; s++) {
      if (_stepIndex >= _stageFirstStep[s]) {
        stage = s;
      } else {
        break;
      }
    }
    return stage;
  }

  int get countdownSeconds {
    final elapsed = _controller.value * _currentStep.seconds;
    return (_remainingAtStep[_stepIndex] - elapsed).ceil();
  }

  String get phaseLabel {
    switch (phase) {
      case KegelPhase.getReady:
        return "Get ready";
      case KegelPhase.contract:
        return "Contract";
      case KegelPhase.hold:
        return "Hold";
      case KegelPhase.relax:
      case KegelPhase.wait:
        return "Relax";
      case KegelPhase.rest:
        return "Rest";
      case KegelPhase.complete:
        return "Training complete";
    }
  }

  String get hintLabel {
    switch (phase) {
      case KegelPhase.contract:
        return "Squeeze and lift";
      case KegelPhase.hold:
        return "Keep squeezing";
      case KegelPhase.relax:
      case KegelPhase.wait:
        return "Release slowly";
      case KegelPhase.getReady:
      case KegelPhase.rest:
        return "Breathe steadily and stay relaxed";
      case KegelPhase.complete:
        return "Well done";
    }
  }

  void start() => _runStep();

  void pause() {
    if (isComplete) return;
    _isPaused = true;
    _controller.stop();
    notifyListeners();
  }

  void resume() {
    if (isComplete) return;
    _isPaused = false;
    _controller.forward();
    notifyListeners();
  }

  void skipToNextStage() {
    if (isComplete) return;
    final next = currentStageIndex + 1;
    _jumpToStep(next < _stageFirstStep.length
        ? _stageFirstStep[next]
        : _steps.length - 1);
  }

  void skipToPreviousStage() {
    if (isComplete) return;
    final stage = currentStageIndex;
    final stageStart = _stageFirstStep[stage];
    // Media-player semantics: restart the current stage unless we're within
    // the first couple of seconds of its first step, in which case step back
    // to the previous stage.
    final nearStart = _stepIndex == stageStart &&
        _controller.value * _currentStep.seconds < 2.0;
    if (nearStart && stage > 0) {
      _jumpToStep(_stageFirstStep[stage - 1]);
    } else {
      _jumpToStep(stageStart);
    }
  }

  void _jumpToStep(int index) {
    _stepIndex = index;
    _runStep();
  }

  void _advance() {
    if (_stepIndex < _steps.length - 1) {
      _stepIndex++;
      _runStep();
    }
  }

  void _runStep() {
    if (_disposed) return;
    final step = _currentStep;
    if (step.phase == KegelPhase.complete) {
      _controller.stop();
      _controller.value = 0;
      notifyListeners();
      return;
    }
    _controller.duration =
        Duration(milliseconds: (step.seconds * 1000).round());
    _fill = Tween(begin: step.fillFrom, end: step.fillTo).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.value = 0;
    if (!_isPaused) _controller.forward();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    super.dispose();
  }
}

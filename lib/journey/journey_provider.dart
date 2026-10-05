import 'package:flutter/material.dart';

class JourneyStep {
  final String name;
  final IconData icon;

  const JourneyStep({required this.name, required this.icon});
}

/// The ways a step can celebrate being completed. This is a tech demo, so
/// the user can flip between them to see which feels best.
enum JourneyEffect { burst, confetti, shockwave, hold }

extension JourneyEffectInfo on JourneyEffect {
  String get friendlyName {
    switch (this) {
      case JourneyEffect.burst:
        return "Burst";
      case JourneyEffect.confetti:
        return "Confetti";
      case JourneyEffect.shockwave:
        return "Shockwave";
      case JourneyEffect.hold:
        return "Hold";
    }
  }

  IconData get iconData {
    switch (this) {
      case JourneyEffect.burst:
        return Icons.auto_awesome;
      case JourneyEffect.confetti:
        return Icons.celebration;
      case JourneyEffect.shockwave:
        return Icons.waves;
      case JourneyEffect.hold:
        return Icons.touch_app;
    }
  }
}

/// In-memory state for the journey demo. Steps are hard coded and progress
/// is not persisted - it survives switching tabs but not an app restart.
class JourneyProvider extends ChangeNotifier {
  static const List<JourneyStep> steps = [
    JourneyStep(name: "Noji", icon: Icons.style),
    JourneyStep(name: "Mauril", icon: Icons.live_tv),
    JourneyStep(name: "Podcast", icon: Icons.podcasts),
    JourneyStep(name: "Verbs", icon: Icons.menu_book),
  ];

  int _completed = 0;
  JourneyEffect _effect = JourneyEffect.burst;

  /// Steps must be completed in order, so this is also the index of the
  /// current step.
  int get completed => _completed;
  bool get isFinished => _completed >= steps.length;
  JourneyEffect get effect => _effect;

  set effect(JourneyEffect value) {
    _effect = value;
    notifyListeners();
  }

  void complete(int index) {
    if (index != _completed) return;
    _completed++;
    notifyListeners();
  }

  void reset() {
    _completed = 0;
    notifyListeners();
  }
}

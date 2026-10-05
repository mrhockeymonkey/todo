import 'package:flutter/material.dart';

class JourneyStep {
  final String name;
  final IconData icon;

  const JourneyStep({required this.name, required this.icon});
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

  /// Steps must be completed in order, so this is also the index of the
  /// current step.
  int get completed => _completed;
  bool get isFinished => _completed >= steps.length;
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

import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:todo/celebration/effects/circuit_effect.dart';

/// The animation played when a day plan task is swiped done. These are
/// experiments to compare on-device; [shuffle] picks a different one each
/// swipe and names it so you know which you saw.
enum CelebrationStyle {
  none("None", "Just mark it done"),
  circuit("Circuit", "A red line loops the loop into the done item"),
  ribbon("Ribbon", "A rainbow ribbon swoops to where the done item lands"),
  streamer("Streamer", "Party streamers loop-the-loop into place"),
  comet("Comet", "A glowing comet with a sparkle tail, then a burst"),
  flyIn("Fly-in", "The task itself flies into the done list"),
  confetti("Confetti pop", "A confetti burst and a golden glow"),
  shuffle("Shuffle", "A different one every swipe");

  final String label;
  final String description;

  const CelebrationStyle(this.label, this.description);

  /// The styles that actually animate.
  static List<CelebrationStyle> get playable =>
      values.where((s) => s != none && s != shuffle).toList();
}

/// Remembers the chosen [CelebrationStyle], and the Circuit line's
/// tunables, in Localstore.
class CelebrationSettings with ChangeNotifier {
  static const String _collection = "settings";
  static const String _doc = "celebration";

  final bool _persist;
  CelebrationStyle _style;
  CircuitOptions _circuit;

  CelebrationSettings({
    CelebrationStyle initial = CelebrationStyle.circuit,
    CircuitOptions circuit = const CircuitOptions(),
    bool persist = true,
  }) : _style = initial,
       _circuit = circuit,
       _persist = persist {
    if (_persist) _load();
  }

  CelebrationStyle get style => _style;

  set style(CelebrationStyle value) {
    if (value == _style) return;
    _style = value;
    notifyListeners();
    save();
  }

  CircuitOptions get circuit => _circuit;

  /// Updates the Circuit options in memory; call [save] to keep them (e.g.
  /// when a slider is let go, rather than on every step of the drag).
  set circuit(CircuitOptions value) {
    _circuit = value;
    notifyListeners();
  }

  Future<void> save() async {
    if (!_persist) return;
    await Localstore.instance.collection(_collection).doc(_doc).set({
      "style": _style.name,
      for (final param in CircuitParam.values)
        param.storageKey: _circuit[param],
    });
  }

  Future<void> _load() async {
    try {
      final data =
          await Localstore.instance.collection(_collection).doc(_doc).get();
      if (data == null) return;
      final name = data["style"];
      final stored = CelebrationStyle.values.where((s) => s.name == name);
      if (stored.isNotEmpty) _style = stored.first;
      for (final param in CircuitParam.values) {
        final value = data[param.storageKey];
        if (value is num) {
          _circuit = _circuit.withValue(param, value.toDouble());
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Could not load celebration setting: $e");
    }
  }
}

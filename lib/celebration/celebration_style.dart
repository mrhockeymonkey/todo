import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';

/// The animation played when a day plan task is swiped done. These are
/// experiments to compare on-device; [shuffle] picks a different one each
/// swipe and names it so you know which you saw.
enum CelebrationStyle {
  none("None", "Just mark it done"),
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

/// Remembers the chosen [CelebrationStyle] in Localstore.
class CelebrationSettings with ChangeNotifier {
  static const String _collection = "settings";
  static const String _doc = "celebration";

  final bool _persist;
  CelebrationStyle _style;

  CelebrationSettings({
    CelebrationStyle initial = CelebrationStyle.ribbon,
    bool persist = true,
  }) : _style = initial,
       _persist = persist {
    if (_persist) _load();
  }

  CelebrationStyle get style => _style;

  set style(CelebrationStyle value) {
    if (value == _style) return;
    _style = value;
    notifyListeners();
    if (_persist) {
      Localstore.instance.collection(_collection).doc(_doc).set({
        "style": value.name,
      });
    }
  }

  Future<void> _load() async {
    try {
      final data =
          await Localstore.instance.collection(_collection).doc(_doc).get();
      final name = data?["style"];
      final stored = CelebrationStyle.values.where((s) => s.name == name);
      if (stored.isNotEmpty && stored.first != _style) {
        _style = stored.first;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Could not load celebration setting: $e");
    }
  }
}

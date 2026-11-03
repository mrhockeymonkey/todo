import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo/celebration/celebration_effect.dart';
import 'package:todo/celebration/celebration_style.dart';

/// Coordinates completion celebrations for one screen.
///
/// Done items register themselves (see `CelebrationTarget`) so an effect can
/// fly to wherever the item lands after it re-sorts. While an effect is in
/// flight the done item is kept hidden, then revealed as the effect arrives.
class CelebrationController with ChangeNotifier {
  final Map<String, BuildContext> _targets = {};
  final Set<String> _hidden = {};
  final List<OverlayEntry> _entries = [];
  final Random _random;
  bool _disposed = false;

  CelebrationController({Random? random}) : _random = random ?? Random();

  void register(String taskId, BuildContext context) =>
      _targets[taskId] = context;

  void unregister(String taskId, BuildContext context) {
    if (identical(_targets[taskId], context)) _targets.remove(taskId);
  }

  bool isHidden(String taskId) => _hidden.contains(taskId);

  /// Whether an effect is currently playing.
  bool get isPlaying => _entries.isNotEmpty;

  /// The registered done item's row in global coordinates, if laid out.
  Rect? targetRect(String taskId) {
    final context = _targets[taskId];
    if (context == null || !context.mounted) return null;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    if (box.size.height < 1) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Plays [style] for [request]. Call before saving the done task so its
  /// done item starts hidden.
  void celebrate(
    BuildContext context, {
    required CelebrationRequest request,
    required CelebrationStyle style,
  }) {
    String? label;
    var chosen = style;
    if (style == CelebrationStyle.shuffle) {
      final options = CelebrationStyle.playable;
      chosen = options[_random.nextInt(options.length)];
      label = chosen.label;
    }

    final effect = CelebrationEffect.forStyle(chosen, request, _random);
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (effect == null || overlay == null) return;

    final id = request.taskId;
    _hidden.add(id);
    notifyListeners();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder:
          (_) => CelebrationOverlay(
            effect: effect,
            request: request,
            label: label,
            resolveTarget: () => targetRect(id),
            onLanded: () {
              HapticFeedback.mediumImpact();
              _reveal(id);
            },
            onFinished: () {
              _reveal(id);
              _entries.remove(entry);
              entry.remove();
            },
          ),
    );
    _entries.add(entry);
    overlay.insert(entry);
  }

  void _reveal(String taskId) {
    if (_disposed) return;
    if (_hidden.remove(taskId)) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final entry in _entries) {
      entry.remove();
    }
    _entries.clear();
    super.dispose();
  }
}

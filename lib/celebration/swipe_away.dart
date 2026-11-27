import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/celebration/circuit_animation.dart';
import 'package:todo/celebration/circuit_settings.dart';

/// Wraps a card so it can be sent off like a swiped-done task: call
/// [SwipeAwayState.play] through a key. The card slides off to the right, then
/// the completion lines run to just above whatever is below it. They are drawn
/// in the overlay, so they carry on even if the card is then removed.
class SwipeAway extends StatefulWidget {
  /// The gap between this widget and whatever is below it.
  final double gapBelow;
  final Widget child;

  const SwipeAway({super.key, required this.gapBelow, required this.child});

  @override
  State<SwipeAway> createState() => SwipeAwayState();
}

class SwipeAwayState extends State<SwipeAway>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  /// Completes when the card has gone. It stays gone until [reset].
  Future<void> play() async {
    // Where the card is now, before it starts to move.
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final source = box.localToGlobal(Offset.zero) & box.size;

    await _slide.forward(from: 0).orCancel.catchError((_) {});
    if (mounted && _slide.isCompleted) _showLines(source);
  }

  /// Brings the card back.
  void reset() => _slide.reset();

  /// The day plan's completion lines, with the same settings. There is no done
  /// item to run to, so they end at the bottom of the gap below the card.
  void _showLines(Rect source) {
    final options =
        context.read<CircuitSettings?>()?.options ?? const CircuitOptions();
    final end = Rect.fromLTWH(
      source.left,
      source.bottom + widget.gapBelow - options.thickness / 2,
      source.width,
      0,
    );

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder:
          (_) => CircuitAnimation(
            options: options,
            request: CircuitRequest(
              taskId: "swipe-away",
              colour: AppColour.colorCustom,
              source: source,
            ),
            resolveTarget: () => end,
            onLanded: HapticFeedback.mediumImpact,
            onFinished: () => entry.remove(),
          ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SlideTransition(
    // A little over its own width, to clear the side margin too.
    position: Tween(
      begin: Offset.zero,
      end: const Offset(1.1, 0),
    ).chain(CurveTween(curve: Curves.easeIn)).animate(_slide),
    child: widget.child,
  );
}

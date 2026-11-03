import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/celebration/celebration_style.dart';
import 'package:todo/celebration/effects/comet_effect.dart';
import 'package:todo/celebration/effects/confetti_pop_effect.dart';
import 'package:todo/celebration/effects/fly_in_effect.dart';
import 'package:todo/celebration/effects/ribbon_effect.dart';
import 'package:todo/celebration/effects/streamer_effect.dart';
import 'package:todo/celebration/flight_path.dart';

/// What was completed and where it was when it was swiped away.
class CelebrationRequest {
  final String taskId;
  final String title;
  final Color colour;

  /// The swiped row, in global coordinates.
  final Rect source;

  const CelebrationRequest({
    required this.taskId,
    required this.title,
    required this.colour,
    required this.source,
  });
}

/// Everything an effect needs to draw one frame, in overlay coordinates.
class CelebrationFrame {
  /// Overall progress, 0 to 1.
  final double t;
  final Rect source;
  final Offset start;

  /// Where the effect should land: the leading icon of the done item. This
  /// chases the live position of that item, so it copes with the list
  /// re-sorting and scrolling mid-flight.
  final Offset end;

  /// The done item's row, once it has been laid out.
  final Rect? target;
  final CelebrationRequest request;

  CelebrationFrame({
    required this.t,
    required this.source,
    required this.start,
    required this.end,
    required this.target,
    required this.request,
  });

  late final FlightPath flight = FlightPath(start, end);

  /// Progress through the stretch of [t] between [from] and [to], clamped.
  double phase(double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);
}

abstract class CelebrationEffect {
  /// Total running time.
  Duration get duration;

  /// The fraction of [duration] at which the effect reaches the done item,
  /// which is then revealed.
  double get landAt;

  /// Where the effect sets off from, given the swiped row.
  Offset launchPoint(Rect source) =>
      Offset(source.right - 28, source.center.dy);

  Widget build(BuildContext context, CelebrationFrame frame);

  static CelebrationEffect? forStyle(
    CelebrationStyle style,
    CelebrationRequest request,
    Random random,
  ) => switch (style) {
    CelebrationStyle.ribbon => RibbonEffect(random),
    CelebrationStyle.streamer => StreamerEffect(random),
    CelebrationStyle.comet => CometEffect(random),
    CelebrationStyle.flyIn => FlyInEffect(request),
    CelebrationStyle.confetti => ConfettiPopEffect(random),
    CelebrationStyle.none || CelebrationStyle.shuffle => null,
  };
}

/// A rainbow colour, cycling every 360 degrees of [hue].
Color rainbow(double hue, {double alpha = 1}) =>
    HSVColor.fromAHSV(alpha.clamp(0.0, 1.0), hue % 360, 0.72, 1).toColor();

/// Plays one [CelebrationEffect] full screen in the overlay. Ignores touches.
class CelebrationOverlay extends StatefulWidget {
  final CelebrationEffect effect;
  final CelebrationRequest request;

  /// The done item's row in global coordinates, or null if not laid out yet.
  final Rect? Function() resolveTarget;
  final VoidCallback onLanded;
  final VoidCallback onFinished;

  /// Shown briefly at the top so you know which effect Shuffle picked.
  final String? label;

  const CelebrationOverlay({
    super.key,
    required this.effect,
    required this.request,
    required this.resolveTarget,
    required this.onLanded,
    required this.onFinished,
    this.label,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _landed = false;
  Offset? _end;
  Rect? _target;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.effect.duration,
    )..addListener(_tick);
    _controller.forward().whenComplete(() {
      _land();
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tick() {
    if (_controller.value >= widget.effect.landAt) _land();
  }

  void _land() {
    if (_landed) return;
    _landed = true;
    widget.onLanded();
  }

  Rect _toLocal(Rect global) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return global;
    return box.globalToLocal(global.topLeft) & global.size;
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final source = _toLocal(widget.request.source);
        final resolved = widget.resolveTarget();
        if (resolved != null) _target = _toLocal(resolved);

        // Until the done item exists, guess it lands a row below.
        final desired =
            _target != null
                ? Offset(_target!.left + 28, _target!.center.dy)
                : Offset(source.left + 28, source.bottom + source.height / 2);
        // Ease towards the real landing spot rather than jumping to it.
        _end =
            _end == null || _landed ? desired : Offset.lerp(_end, desired, 0.3);

        final frame = CelebrationFrame(
          t: _controller.value,
          source: source,
          start: widget.effect.launchPoint(source),
          end: _end!,
          target: _target,
          request: widget.request,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: widget.effect.build(context, frame)),
            if (widget.label != null) _buildLabel(frame.t),
          ],
        );
      },
    ),
  );

  Widget _buildLabel(double t) {
    final fade = t < 0.8 ? 1.0 : 1 - (t - 0.8) / 0.2;
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 64,
      left: 0,
      right: 0,
      child: Center(
        child: Opacity(
          opacity: fade.clamp(0.0, 1.0),
          child: Material(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text(
                widget.label!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

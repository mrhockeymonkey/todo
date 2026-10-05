import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo/app_colour.dart';

enum JourneyNodeState { locked, current, done }

/// A chunky "3D" button on the journey path. It sits on a darker base and
/// presses down into it when touched, bounces when it changes state and, for
/// the current step, pulses with a bobbing call-to-action bubble.
class JourneyNode extends StatefulWidget {
  static const double size = 76;
  static const double depth = 7;
  static const double boxWidth = 140;

  final IconData icon;
  final IconData doneIcon;
  final String label;
  final JourneyNodeState state;

  /// When true the current step must be held down until a ring fills.
  final bool holdToComplete;
  final VoidCallback? onComplete;

  const JourneyNode({
    super.key,
    required this.icon,
    required this.label,
    required this.state,
    this.doneIcon = Icons.check_rounded,
    this.holdToComplete = false,
    this.onComplete,
  });

  @override
  State<JourneyNode> createState() => _JourneyNodeState();
}

class _NodePalette {
  final Color top;
  final Color base;
  final Color icon;
  final Color label;

  const _NodePalette(this.top, this.base, this.icon, this.label);
}

class _JourneyNodeState extends State<JourneyNode>
    with TickerProviderStateMixin {
  static final _bounceScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.8,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 12,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.8,
        end: 1.25,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 22,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.25,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 66,
    ),
  ]);

  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    reverseDuration: const Duration(milliseconds: 250),
  );
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  bool _pressed = false;
  int _holdTick = 0;

  bool get _isCurrent => widget.state == JourneyNodeState.current;
  bool get _isHoldMode => widget.holdToComplete && _isCurrent;

  @override
  void initState() {
    super.initState();
    if (_isCurrent) _pulse.repeat();
    _hold.addListener(_onHoldProgress);
    _hold.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(JourneyNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state == widget.state) return;

    // Unlocking or completing gets a squash-and-stretch pop. Going back
    // (a reset) just snaps.
    if (widget.state.index > oldWidget.state.index) _bounce.forward(from: 0);

    if (_isCurrent) {
      _pulse.repeat();
    } else {
      _pulse.reset();
      _hold.value = 0;
      _holdTick = 0;
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    _pulse.dispose();
    _hold.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _onHoldProgress() {
    // Haptic ticks while filling, getting stronger near the end.
    final tick = (_hold.value * 10).floor();
    if (tick > _holdTick && _hold.status == AnimationStatus.forward) {
      tick >= 7
          ? HapticFeedback.lightImpact()
          : HapticFeedback.selectionClick();
    }
    _holdTick = tick;
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
    if (_isHoldMode) _hold.forward();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    if (_isHoldMode) {
      if (!_hold.isCompleted) _hold.reverse();
      return;
    }
    switch (widget.state) {
      case JourneyNodeState.locked:
        HapticFeedback.lightImpact();
        _shake.forward(from: 0);
        break;
      case JourneyNodeState.current:
        widget.onComplete?.call();
        break;
      case JourneyNodeState.done:
        HapticFeedback.selectionClick();
        break;
    }
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    if (_isHoldMode && !_hold.isCompleted) _hold.reverse();
  }

  _NodePalette get _palette {
    switch (widget.state) {
      case JourneyNodeState.locked:
        return _NodePalette(
          Colors.grey.shade300,
          Colors.grey.shade400,
          Colors.grey.shade500,
          Colors.grey.shade500,
        );
      case JourneyNodeState.current:
        return _NodePalette(
          const Color(0xFF1287C4),
          AppColour.colorCustom.shade300,
          Colors.white,
          AppColour.colorCustom,
        );
      case JourneyNodeState.done:
        return const _NodePalette(
          Color(0xFFFFC107),
          Color(0xFFE09B00),
          Colors.white,
          Color(0xFFC88A00),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const size = JourneyNode.size;
    const depth = JourneyNode.depth;
    const boxWidth = JourneyNode.boxWidth;
    const ringRadius = size / 2 + 26;
    final palette = _palette;

    return AnimatedBuilder(
      animation: Listenable.merge([_bounce, _pulse, _hold, _shake]),
      builder: (context, _) {
        final scale =
            _bounceScale.evaluate(_bounce) *
            (1 - 0.1 * Curves.easeOut.transform(_hold.value));
        final shakeDx = sin(_shake.value * pi * 6) * 8 * (1 - _shake.value);
        // Tremble as the hold nears completion to build anticipation.
        final trembleDx =
            _hold.value > 0.5
                ? sin(_hold.value * 140) * 2.5 * (_hold.value - 0.5) * 2
                : 0.0;

        return SizedBox(
          width: boxWidth,
          height: size + depth + 30,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_isCurrent)
                Positioned(
                  left: boxWidth / 2 - ringRadius,
                  top: size / 2 - ringRadius,
                  width: ringRadius * 2,
                  height: ringRadius * 2,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _RingPainter(
                        pulse: _pulse.value,
                        hold: _hold.value,
                        colour: palette.top,
                      ),
                    ),
                  ),
                ),
              // Keyed so the GestureDetector survives the ring above being
              // removed mid-press when a hold completes.
              Positioned(
                key: const ValueKey("button"),
                left: boxWidth / 2 - size / 2,
                top: 0,
                width: size,
                height: size + depth,
                child: Transform.translate(
                  offset: Offset(shakeDx + trembleDx, 0),
                  child: Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: _onTapDown,
                      onTapUp: _onTapUp,
                      onTapCancel: _onTapCancel,
                      child: _buildButton(palette),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: size + depth + 6,
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: palette.label,
                  ),
                ),
              ),
              if (_isCurrent)
                Positioned(
                  left: 0,
                  right: 0,
                  top: -60 + sin(_pulse.value * 2 * pi) * 4,
                  child: IgnorePointer(
                    child: Center(
                      child: _Bubble(
                        text: widget.holdToComplete ? "HOLD" : "START",
                        colour: palette.top,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(_NodePalette palette) {
    const size = JourneyNode.size;
    const depth = JourneyNode.depth;
    const duration = Duration(milliseconds: 120);

    return Stack(
      children: [
        Positioned(
          top: depth,
          left: 0,
          child: AnimatedContainer(
            duration: duration,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: palette.base,
              shape: BoxShape.circle,
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 60),
          top: _pressed ? depth : 0,
          left: 0,
          child: AnimatedContainer(
            duration: duration,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                radius: 0.9,
                colors: [
                  Color.lerp(palette.top, Colors.white, 0.25)!,
                  palette.top,
                ],
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 80),
              switchInCurve: Curves.elasticOut,
              transitionBuilder:
                  (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
              child: Icon(
                widget.state == JourneyNodeState.done
                    ? widget.doneIcon
                    : widget.icon,
                key: ValueKey(widget.state == JourneyNodeState.done),
                color: palette.icon,
                size: widget.state == JourneyNodeState.done ? 42 : 34,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The pulsing halo around the current step, plus the fill ring for hold.
class _RingPainter extends CustomPainter {
  final double pulse;
  final double hold;
  final Color colour;

  _RingPainter({required this.pulse, required this.hold, required this.colour});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const nodeRadius = JourneyNode.size / 2;

    if (hold == 0) {
      canvas.drawCircle(
        center,
        nodeRadius + 4 + 16 * Curves.easeOut.transform(pulse),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = colour.withValues(alpha: 0.5 * (1 - pulse)),
      );
      return;
    }

    final rect = Rect.fromCircle(center: center, radius: nodeRadius + 12);
    canvas.drawCircle(
      center,
      nodeRadius + 12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = Colors.grey.shade300,
    );
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * hold,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFC107),
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.pulse != pulse ||
      oldDelegate.hold != hold ||
      oldDelegate.colour != colour;
}

class _Bubble extends StatelessWidget {
  final String text;
  final Color colour;

  const _Bubble({required this.text, required this.colour});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: colour,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      CustomPaint(size: const Size(16, 8), painter: _BubbleTailPainter()),
    ],
  );
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()
          ..moveTo(0, -2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(size.width, -2)
          ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.grey.shade300,
    );
  }

  @override
  bool shouldRepaint(_BubbleTailPainter oldDelegate) => false;
}

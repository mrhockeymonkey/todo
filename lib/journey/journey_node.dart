import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo/app_colour.dart';

enum JourneyNodeState { locked, current, done }

/// A round, elevated button on the journey path. The current step is
/// completed by holding it down until a ring fills; it pulses with a bobbing
/// call-to-action bubble until then. Nodes bounce when they change state.
class JourneyNode extends StatefulWidget {
  static const double size = 64;
  static const double boxWidth = 120;

  final IconData icon;
  final IconData doneIcon;
  final String label;
  final JourneyNodeState state;
  final VoidCallback? onComplete;

  const JourneyNode({
    super.key,
    required this.icon,
    required this.label,
    required this.state,
    this.doneIcon = Icons.check_rounded,
    this.onComplete,
  });

  @override
  State<JourneyNode> createState() => _JourneyNodeState();
}

class _NodePalette {
  final Color fill;
  final Color icon;
  final Color label;

  const _NodePalette(this.fill, this.icon, this.label);
}

class _JourneyNodeState extends State<JourneyNode>
    with TickerProviderStateMixin {
  static const double _restingElevation = 6;
  static const double _pressedElevation = 1;

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
    if (_isCurrent) _hold.forward();
  }

  void _onTapUp(TapUpDetails _) => _release();

  void _onTapCancel() => _release();

  void _release() {
    setState(() => _pressed = false);
    if (_isCurrent && !_hold.isCompleted) _hold.reverse();
  }

  void _onTap() {
    switch (widget.state) {
      case JourneyNodeState.locked:
        HapticFeedback.lightImpact();
        _shake.forward(from: 0);
        break;
      case JourneyNodeState.current:
      case JourneyNodeState.done:
        break;
    }
  }

  _NodePalette get _palette {
    switch (widget.state) {
      case JourneyNodeState.locked:
        return _NodePalette(
          Colors.grey.shade300,
          Colors.grey.shade500,
          Colors.grey.shade500,
        );
      case JourneyNodeState.current:
        return const _NodePalette(
          Color(0xFF1287C4),
          Colors.white,
          AppColour.colorCustom,
        );
      case JourneyNodeState.done:
        return const _NodePalette(
          Color(0xFFFFC107),
          Colors.white,
          Color(0xFFC88A00),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const size = JourneyNode.size;
    const boxWidth = JourneyNode.boxWidth;
    const ringRadius = size / 2 + 22;
    final palette = _palette;

    return AnimatedBuilder(
      animation: Listenable.merge([_bounce, _pulse, _hold, _shake]),
      builder: (context, _) {
        final scale =
            _bounceScale.evaluate(_bounce) *
            (1 - 0.08 * Curves.easeOut.transform(_hold.value));
        final shakeDx = sin(_shake.value * pi * 6) * 8 * (1 - _shake.value);
        // Tremble as the hold nears completion to build anticipation.
        final trembleDx =
            _hold.value > 0.5
                ? sin(_hold.value * 140) * 2.5 * (_hold.value - 0.5) * 2
                : 0.0;

        return SizedBox(
          width: boxWidth,
          height: size + 30,
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
                        colour: palette.fill,
                      ),
                    ),
                  ),
                ),
              // Keyed so the button survives the ring above being removed
              // mid-press when a hold completes.
              Positioned(
                key: const ValueKey("button"),
                left: boxWidth / 2 - size / 2,
                top: 0,
                width: size,
                height: size,
                child: Transform.translate(
                  offset: Offset(shakeDx + trembleDx, 0),
                  child: Transform.scale(
                    scale: scale,
                    child: _buildButton(palette),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: size + 6,
                // Backed by the page colour so the path passes behind it.
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: palette.label,
                      ),
                    ),
                  ),
                ),
              ),
              if (_isCurrent)
                Positioned(
                  left: 0,
                  right: 0,
                  top: -54 + sin(_pulse.value * 2 * pi) * 4,
                  child: IgnorePointer(
                    child: Center(
                      child: _Bubble(text: "HOLD", colour: palette.fill),
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
    final isDone = widget.state == JourneyNodeState.done;

    // Material animates both the elevation and the colour change for us.
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: palette.fill,
      elevation: _pressed ? _pressedElevation : _restingElevation,
      animationDuration: const Duration(milliseconds: 120),
      child: InkWell(
        customBorder: const CircleBorder(),
        splashColor: Colors.white24,
        highlightColor: Colors.black12,
        onTap: _onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            reverseDuration: const Duration(milliseconds: 80),
            switchInCurve: Curves.elasticOut,
            transitionBuilder:
                (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
            child: Icon(
              isDone ? widget.doneIcon : widget.icon,
              key: ValueKey(isDone),
              color: palette.icon,
              size: isDone ? 36 : 28,
            ),
          ),
        ),
      ),
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
        nodeRadius + 4 + 14 * Curves.easeOut.transform(pulse),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = colour.withValues(alpha: 0.5 * (1 - pulse)),
      );
      return;
    }

    const ringRadius = nodeRadius + 10;
    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = Colors.grey.shade300,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: ringRadius),
      -pi / 2,
      2 * pi * hold,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
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

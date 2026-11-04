import 'dart:math';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:todo/celebration/circuit_settings.dart';

/// A task that was swiped done, and where its row was.
class CircuitRequest {
  final String taskId;

  /// Colour of the leading line; followers are lighter and darker shades.
  final Color colour;

  /// The swiped row, in global coordinates.
  final Rect source;

  const CircuitRequest({
    required this.taskId,
    required this.colour,
    required this.source,
  });
}

/// The completion animation, played full screen in the overlay.
///
/// A solid line starts where the swiped row was thrown to (its right-hand
/// side), runs left along the row to the middle of the screen, loops the
/// loop (a 270° turn) and drops straight down into the done item, as if the
/// task rode the line there. Followers in other shades run the same route a
/// little behind, to either side. With gravity the lines slow as they climb
/// into the loop and speed up as they drop, like a rollercoaster.
class CircuitAnimation extends StatefulWidget {
  static const double loopRadius = 36;

  /// Stop waiting if the done item never appears.
  static const Duration giveUpAfter = Duration(seconds: 3);

  final CircuitOptions options;
  final CircuitRequest request;

  /// The done item's row in global coordinates, or null if not laid out yet.
  final Rect? Function() resolveTarget;

  /// Called once, when the leading line reaches the done item.
  final VoidCallback onLanded;

  /// Called once, when the last line has run in.
  final VoidCallback onFinished;

  const CircuitAnimation({
    super.key,
    required this.options,
    required this.request,
    required this.resolveTarget,
    required this.onLanded,
    required this.onFinished,
  });

  @override
  State<CircuitAnimation> createState() => _CircuitAnimationState();
}

class _CircuitAnimationState extends State<CircuitAnimation>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  bool _hasTarget = false;
  double? _endY;
  bool _landed = false;
  bool _finished = false;

  CircuitOptions get _options => widget.options;
  double get _seconds => _elapsed.inMicroseconds / 1e6;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    _elapsed = elapsed;
    if (!_hasTarget) {
      if (elapsed > CircuitAnimation.giveUpAfter) return _finish();
    } else {
      final motion = _motion();
      if (!_landed && motion.distanceAt(_seconds) >= motion.length) {
        _landed = true;
        widget.onLanded();
      }
      final last = _seconds - _options.followers * _options.followerDelay;
      if (motion.distanceAt(last) - _options.length >= motion.length) {
        return _finish();
      }
    }
    setState(() {});
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _ticker.stop();
    if (!_landed) {
      _landed = true;
      widget.onLanded();
    }
    widget.onFinished();
  }

  Rect _toLocal(Rect global) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return global;
    return box.globalToLocal(global.topLeft) & global.size;
  }

  /// The route and motion for this frame. The route follows the done item if
  /// it moves (e.g. the list re-sorts or scrolls).
  CircuitMotion? _cachedMotion;
  Duration? _cachedAt;

  CircuitMotion _motion() {
    if (_cachedAt == _elapsed && _cachedMotion != null) return _cachedMotion!;

    final source = _toLocal(widget.request.source);
    final target = widget.resolveTarget();
    if (target != null) _hasTarget = true;
    // Until the done item exists, guess it lands a row below; then ease
    // towards its real position rather than jumping there.
    final desired =
        target != null
            ? _toLocal(target).center.dy
            : source.bottom + source.height / 2;
    _endY =
        _endY == null || _landed ? desired : _endY! + (desired - _endY!) * 0.3;

    final box = context.findRenderObject();
    final size =
        box is RenderBox && box.hasSize ? box.size : MediaQuery.sizeOf(context);
    final contentTop = MediaQuery.paddingOf(context).top + kToolbarHeight;
    // Keep the outermost follower clear of the app bar too.
    final spread = _options.followers > 0 ? _options.followerOffset : 0.0;
    final widest =
        _options.thickness / 2 + spread * ((_options.followers + 1) ~/ 2);

    final route = circuitRoute(
      start: Offset(source.right - 16, source.center.dy),
      endY: _endY!,
      width: size.width,
      top: contentTop + 8 + widest,
      radius: CircuitAnimation.loopRadius + widest,
    );
    _cachedAt = _elapsed;
    return _cachedMotion = CircuitMotion(route, _options);
  }

  @override
  Widget build(BuildContext context) {
    final motion = _motion();
    final lines = [
      for (var i = 0; i <= _options.followers; i++)
        _line(
          motion,
          i,
          motion.distanceAt(_seconds - i * _options.followerDelay),
        ),
    ];
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        // Followers underneath, the leader on top.
        painter: _CircuitPainter(motion.metric, lines.reversed.toList()),
      ),
    );
  }

  /// Line [index] (0 is the leader) with its head at [head] along the route.
  _Line _line(CircuitMotion motion, int index, double head) {
    final from = max(0.0, head - _options.length);
    final to = min(motion.length, head);
    final colour = widget.request.colour;
    if (index == 0) return _Line(from, to, 0, _options.thickness, colour);

    // Followers alternate sides and shades: 1 to one side and lighter, 2 to
    // the other and darker, 3 further out and lighter still, ...
    final rank = (index + 1) ~/ 2;
    final side = index.isOdd ? 1 : -1;
    final ranks = (_options.followers + 1) ~/ 2;
    final shift = _options.shadeSpread * 0.3 * rank / ranks;
    final hsl = HSLColor.fromColor(colour);
    final shade = hsl.withLightness(
      (hsl.lightness + side * shift).clamp(0.15, 0.9),
    );
    return _Line(
      from,
      to,
      side * rank * _options.followerOffset,
      _options.followerThickness,
      shade.toColor(),
    );
  }
}

/// The route plus how far along it a line is after a given time.
///
/// Without gravity a line moves at a constant speed. With it, the speed at
/// each point follows energy conservation, v² = v₀² + 2g·(drop since the
/// start), never going below the minimum speed: slowest at the top of the
/// loop, fastest at the bottom of the drop.
class CircuitMotion {
  static const double _step = 2;

  final PathMetric metric;
  final double length;
  final CircuitOptions options;

  /// Seconds taken to reach each [_step] pixels along the route.
  late final List<double> _times;
  late final double _endSpeed;

  CircuitMotion(Path route, this.options)
    : metric = route.computeMetrics().first,
      length = route.computeMetrics().first.length {
    final startY = metric.getTangentForOffset(0)!.position.dy;
    final steps = (length / _step).ceil();
    final times = List<double>.filled(steps + 1, 0);
    for (var i = 1; i <= steps; i++) {
      final s = min(length, (i - 0.5) * _step);
      final y = metric.getTangentForOffset(s)!.position.dy;
      times[i] = times[i - 1] + _step / _speedAt(y - startY);
    }
    _times = times;
    final endY = metric.getTangentForOffset(length)!.position.dy;
    _endSpeed = _speedAt(endY - startY);
  }

  double _speedAt(double drop) {
    final v0 = options.speed;
    final v2 = v0 * v0 + 2 * options.gravity * drop;
    return max(options.minSpeed, sqrt(max(0, v2)));
  }

  /// Distance along the route after [seconds]. Negative before the start;
  /// past [length] after the end, carrying on at the final speed, so a
  /// line's tail can run in after its head.
  double distanceAt(double seconds) {
    if (seconds <= 0) return seconds * options.speed;
    final total = _times.last;
    if (seconds >= total) return length + (seconds - total) * _endSpeed;

    var lo = 0, hi = _times.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) >> 1;
      _times[mid] <= seconds ? lo = mid : hi = mid;
    }
    final f = (seconds - _times[lo]) / (_times[hi] - _times[lo]);
    return min(length, (lo + f) * _step);
  }
}

/// The route: from [start] left to the middle of the screen, a 270° loop,
/// then straight to [endY]. The loop goes up and over when the done item is
/// below, and down and under when it is above, and is shrunk if needed to
/// stay below [top].
Path circuitRoute({
  required Offset start,
  required double endY,
  required double width,
  required double top,
  double radius = CircuitAnimation.loopRadius,
}) {
  final mid = width / 2;
  final y = start.dy;
  final goingDown = endY >= y - radius;
  // Keep an upward loop clear of the app bar.
  final r = goingDown ? max(8.0, min(radius, (y - top) / 2)) : radius;
  // The loop's centre sits so the line leaves it heading straight down (or
  // up) along the middle of the screen.
  final centre = Offset(mid - r, goingDown ? y - r : y + r);
  final startX = max(start.dx, centre.dx + 1);

  return Path()
    ..moveTo(startX, y)
    ..lineTo(centre.dx, y)
    // Clockwise from the bottom of the circle round to its right-hand side
    // (or anticlockwise from the top, when heading up).
    ..arcTo(
      Rect.fromCircle(center: centre, radius: r),
      goingDown ? pi / 2 : -pi / 2,
      goingDown ? 3 * pi / 2 : -3 * pi / 2,
      false,
    )
    ..lineTo(mid, endY);
}

/// One line to draw: the stretch [from]–[to] of the route, shifted [side]
/// pixels sideways from it.
class _Line {
  final double from;
  final double to;
  final double side;
  final double thickness;
  final Color colour;

  const _Line(this.from, this.to, this.side, this.thickness, this.colour);
}

class _CircuitPainter extends CustomPainter {
  static const double _sample = 3;

  final PathMetric metric;
  final List<_Line> lines;

  _CircuitPainter(this.metric, this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    for (final line in lines) {
      if (line.to <= line.from) continue;
      paint
        ..strokeWidth = line.thickness
        ..color = line.colour;
      canvas.drawPath(_pathFor(line), paint);
    }
  }

  Path _pathFor(_Line line) {
    if (line.side == 0) return metric.extractPath(line.from, line.to);
    // Offset sideways along the normal, sampling the route.
    final path = Path();
    final count = max(1, ((line.to - line.from) / _sample).ceil());
    for (var i = 0; i <= count; i++) {
      final s = line.from + (line.to - line.from) * i / count;
      final tangent = metric.getTangentForOffset(s)!;
      final v = tangent.vector;
      final p = tangent.position + Offset(-v.dy, v.dx) * line.side;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_CircuitPainter oldDelegate) => true;
}

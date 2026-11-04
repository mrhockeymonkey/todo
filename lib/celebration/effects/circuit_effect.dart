import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/celebration/celebration_effect.dart';

/// Tunables for [CircuitEffect], adjustable in Settings.
class CircuitOptions {
  static const double minThickness = 1;
  static const double maxThickness = 20;
  static const double minSpeed = 200;
  static const double maxSpeed = 3000;

  /// Line width in logical pixels.
  final double thickness;

  /// How fast the line travels, in logical pixels per second.
  final double speed;

  const CircuitOptions({this.thickness = 4, this.speed = 900});

  CircuitOptions copyWith({double? thickness, double? speed}) => CircuitOptions(
    thickness: thickness ?? this.thickness,
    speed: speed ?? this.speed,
  );
}

/// A single solid line that starts where the swiped tile was thrown to (its
/// right-hand side), runs left along the row to the middle of the screen,
/// loops the loop (a 270° turn) and drops straight down into the done item,
/// as if the task rode the line there.
class CircuitEffect extends CelebrationEffect {
  static const Color colour = Colors.red;
  static const double loopRadius = 36;

  /// Longest stretch of route the line covers at once, in pixels.
  static const double maxLineLength = 160;

  final CircuitOptions options;

  CircuitEffect([this.options = const CircuitOptions()]);

  /// An upper bound; the effect ends as soon as the line has run in.
  @override
  Duration get duration => const Duration(seconds: 8);

  @override
  double get landAt => 1;

  @override
  Offset launchPoint(Rect source) =>
      Offset(source.right - 16, source.center.dy);

  Path _route(CelebrationFrame frame) => circuitRoute(
    start: frame.start,
    endY: frame.end.dy,
    width: frame.size.width,
    top: frame.contentTop + 8 + options.thickness / 2,
    radius: loopRadius + options.thickness / 2,
  );

  double _travelled(CelebrationFrame frame) =>
      options.speed * frame.elapsed.inMicroseconds / 1e6;

  double _lineLength(double routeLength) =>
      min(maxLineLength, routeLength * 0.5);

  /// Only lands once the done item exists; until then the route ends at a
  /// guess, which a fast line could otherwise reach first.
  @override
  bool hasLanded(CelebrationFrame frame) =>
      frame.target != null && _travelled(frame) >= _length(_route(frame));

  @override
  bool isFinished(CelebrationFrame frame) {
    // Give up if the done item never turns up.
    if (frame.target == null) return frame.elapsed > _giveUpAfter;
    final length = _length(_route(frame));
    return _travelled(frame) - _lineLength(length) >= length;
  }

  static const Duration _giveUpAfter = Duration(seconds: 3);

  @override
  Widget build(BuildContext context, CelebrationFrame frame) {
    final route = _route(frame);
    final length = _length(route);
    final head = _travelled(frame);
    final tail = head - _lineLength(length);
    return CustomPaint(
      painter: _CircuitPainter(
        route: route,
        from: max(0, tail),
        to: min(length, head),
        thickness: options.thickness,
      ),
    );
  }

  static double _length(Path path) =>
      path.computeMetrics().fold(0.0, (sum, m) => sum + m.length);
}

/// The route described on [CircuitEffect]: from [start] left to the middle
/// of the screen, a 270° loop, then straight to [endY]. The loop goes up and
/// over when the done item is below, and down and under when it is above,
/// and is shrunk if needed to stay below [top].
Path circuitRoute({
  required Offset start,
  required double endY,
  required double width,
  required double top,
  double radius = 36,
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

class _CircuitPainter extends CustomPainter {
  final Path route;
  final double from;
  final double to;
  final double thickness;

  _CircuitPainter({
    required this.route,
    required this.from,
    required this.to,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (to <= from) return;
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = CircuitEffect.colour;

    var offset = 0.0;
    for (final m in route.computeMetrics()) {
      final a = (from - offset).clamp(0.0, m.length);
      final b = (to - offset).clamp(0.0, m.length);
      if (b > a) canvas.drawPath(m.extractPath(a, b), paint);
      offset += m.length;
    }
  }

  @override
  bool shouldRepaint(_CircuitPainter oldDelegate) =>
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.thickness != thickness;
}

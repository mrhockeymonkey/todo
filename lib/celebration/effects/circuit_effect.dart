import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/celebration/celebration_effect.dart';

/// A single solid line spawned by the swipe that runs round the screen on
/// straight legs joined by rounded corners, ending on the done item as if the
/// task rode the line there:
///
/// right along the row to the screen edge, up to just under the app bar,
/// left to the middle of the screen, then down to the done item.
class CircuitEffect extends CelebrationEffect {
  static const Color colour = Colors.red;
  static const double strokeWidth = 4;

  /// Fraction of the route the line covers at once.
  static const double tailLength = 0.25;

  @override
  Duration get duration => const Duration(milliseconds: 1500);

  /// The head reaches the done item here; the tail then runs in after it,
  /// finishing exactly at the end ([landAt] * (1 + [tailLength]) == 1).
  @override
  double get landAt => 0.8;

  /// Start at the left of the swiped tile.
  @override
  Offset launchPoint(Rect source) => Offset(source.left + 16, source.center.dy);

  @override
  Widget build(BuildContext context, CelebrationFrame frame) {
    final size = MediaQuery.sizeOf(context);
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight + 16;
    final route = circuitRoute(
      start: frame.start,
      endY: frame.end.dy,
      width: size.width,
      top: top,
    );

    final travelled = frame.t / landAt;
    final head = min(1.0, travelled);
    final tail = (travelled - tailLength).clamp(0.0, 1.0);

    return CustomPaint(painter: _CircuitPainter(route, tail, head));
  }
}

/// The route described on [CircuitEffect], from [start] to the middle of the
/// screen at [endY], staying below [top].
Path circuitRoute({
  required Offset start,
  required double endY,
  required double width,
  required double top,
  double margin = 16,
  double radius = 28,
}) {
  final right = width - margin;
  final mid = width / 2;
  // Tighten the corners if a leg is too short for them, e.g. a tile right
  // under the app bar.
  final r = max(2.0, min(radius, min((start.dy - top) / 2, (right - mid) / 2)));
  final bottom = max(endY, top + r);
  final startX = min(start.dx, right - r);

  return Path()
    ..moveTo(startX, start.dy)
    // Along the row to the right edge, turning up.
    ..lineTo(right - r, start.dy)
    ..arcToPoint(
      Offset(right, start.dy - r),
      radius: Radius.circular(r),
      clockwise: false,
    )
    // Up the screen to just under the app bar, turning left.
    ..lineTo(right, top + r)
    ..arcToPoint(
      Offset(right - r, top),
      radius: Radius.circular(r),
      clockwise: false,
    )
    // Across to the middle, turning left again to head down.
    ..lineTo(mid + r, top)
    ..arcToPoint(
      Offset(mid, top + r),
      radius: Radius.circular(r),
      clockwise: false,
    )
    // Down to the done item.
    ..lineTo(mid, bottom);
}

class _CircuitPainter extends CustomPainter {
  final Path route;
  final double tail;
  final double head;

  _CircuitPainter(this.route, this.tail, this.head);

  @override
  void paint(Canvas canvas, Size size) {
    if (head <= tail) return;
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = CircuitEffect.strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = CircuitEffect.colour;

    // The route is one contour, but measure them all in case it ever isn't.
    final metrics = route.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var from = tail * total, to = head * total, offset = 0.0;
    for (final m in metrics) {
      final a = (from - offset).clamp(0.0, m.length);
      final b = (to - offset).clamp(0.0, m.length);
      if (b > a) canvas.drawPath(m.extractPath(a, b), paint);
      offset += m.length;
    }
  }

  @override
  bool shouldRepaint(_CircuitPainter oldDelegate) =>
      oldDelegate.head != head || oldDelegate.tail != tail;
}

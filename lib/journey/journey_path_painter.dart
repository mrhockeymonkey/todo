import 'package:flutter/material.dart';

/// Draws the winding road between journey nodes. [progress] is measured in
/// segments, so 1.5 means the first segment is filled and the second is half
/// way there - this lets the fill "travel" to the next node.
class JourneyPathPainter extends CustomPainter {
  final List<Offset> points;
  final double progress;
  final Color trackColor;
  final Color fillColor;

  JourneyPathPainter({
    required this.points,
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  static Path _segment(Offset from, Offset to) {
    final bend = (to.dy - from.dy) * 0.5;
    return Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(from.dx, from.dy + bend, to.dx, to.dy - bend, to.dx, to.dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final track =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round;
    final fill =
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round;

    final segments = <Path>[
      for (var i = 0; i < points.length - 1; i++)
        _segment(points[i], points[i + 1]),
    ];

    for (final segment in segments) {
      canvas.drawPath(segment, track);
    }

    for (var i = 0; i < segments.length; i++) {
      final amount = (progress - i).clamp(0.0, 1.0);
      if (amount <= 0) break;
      final metric = segments[i].computeMetrics().first;
      canvas.drawPath(metric.extractPath(0, metric.length * amount), fill);
    }
  }

  @override
  bool shouldRepaint(JourneyPathPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.points != points ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}

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

  static const double _strokeWidth = 5;
  static const double _dash = 8;
  static const double _gap = 10;

  /// How far the control points reach along each node's vertical tangent,
  /// as a fraction of the vertical distance. Over 0.5 gives a deeper S-bend.
  static const double _bend = 0.7;

  static Path _segment(Offset from, Offset to) {
    final bend = (to.dy - from.dy) * _bend;
    return Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(from.dx, from.dy + bend, to.dx, to.dy - bend, to.dx, to.dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint stroke(Color colour) =>
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round;
    final track = stroke(trackColor);
    final fill = stroke(fillColor);

    for (var i = 0; i < points.length - 1; i++) {
      final metric = _segment(points[i], points[i + 1]).computeMetrics().first;
      final filled = metric.length * (progress - i).clamp(0.0, 1.0);

      // Each dash is grey, or gold up to how far the fill has travelled.
      for (var start = 0.0; start < metric.length; start += _dash + _gap) {
        final end = (start + _dash).clamp(0.0, metric.length);
        if (filled >= end) {
          canvas.drawPath(metric.extractPath(start, end), fill);
        } else if (filled > start) {
          canvas.drawPath(metric.extractPath(start, filled), fill);
          canvas.drawPath(metric.extractPath(filled, end), track);
        } else {
          canvas.drawPath(metric.extractPath(start, end), track);
        }
      }
    }
  }

  @override
  bool shouldRepaint(JourneyPathPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.points != points ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor;
}

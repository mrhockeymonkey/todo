import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/celebration/celebration_effect.dart';
import 'package:todo/celebration/celebration_painters.dart';

/// A thick rainbow ribbon swoops from the swipe to the done item, its tail
/// chasing the head so it retracts into the landing spot, then a small burst.
class RibbonEffect extends CelebrationEffect {
  final List<CelebrationParticle> _particles;

  RibbonEffect(Random random)
    : _particles = List.generate(
        12,
        (i) => CelebrationParticle.random(random, i, 12),
      );

  @override
  Duration get duration => const Duration(milliseconds: 1300);

  @override
  double get landAt => 0.6;

  @override
  Widget build(BuildContext context, CelebrationFrame frame) =>
      CustomPaint(painter: _RibbonPainter(frame, landAt, _particles));
}

class _RibbonPainter extends CustomPainter {
  static const int _segments = 48;
  static const double _width = 13;

  final CelebrationFrame frame;
  final double landAt;
  final List<CelebrationParticle> particles;

  _RibbonPainter(this.frame, this.landAt, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final t = frame.t;
    final head = Curves.easeInOutCubic.transform(frame.phase(0, landAt));
    final tail = Curves.easeInCubic.transform(frame.phase(0.2, landAt + 0.2));

    if (head > tail) {
      final points = frame.flight.sample(tail, head, _segments);
      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
      final sheen =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withValues(alpha: 0.45);

      for (var i = 0; i < _segments; i++) {
        final f = i / _segments; // 0 at the tail, 1 at the head
        final s = tail + (head - tail) * f;
        final width = _width * (0.35 + 0.65 * sin(pi * (0.15 + 0.85 * f) / 2));
        paint
          ..strokeWidth = width
          ..color = rainbow(330 * s - 200 * t);
        canvas.drawLine(points[i], points[i + 1], paint);

        final n = frame.flight.normalAt(s) * width * 0.22;
        sheen.strokeWidth = width * 0.18;
        canvas.drawLine(points[i] - n, points[i + 1] - n, sheen);
      }
    }

    if (t >= landAt) {
      BurstPainter(
        t: frame.phase(landAt, 1),
        center: frame.end,
        particles: particles,
        scale: 0.5,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_RibbonPainter oldDelegate) => true;
}

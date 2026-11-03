import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/celebration/celebration_effect.dart';
import 'package:todo/celebration/celebration_painters.dart';

/// A glowing comet shoots along the path shedding sparkles, then explodes in
/// a burst on the done item.
class CometEffect extends CelebrationEffect {
  static const int _trailCount = 40;

  final List<CelebrationParticle> _burst;
  final List<_Spark> _trail;

  CometEffect(Random random)
    : _burst = List.generate(
        18,
        (i) => CelebrationParticle.random(random, i, 18),
      ),
      _trail = List.generate(_trailCount, (i) => _Spark.random(random, i));

  @override
  Duration get duration => const Duration(milliseconds: 1350);

  @override
  double get landAt => 0.55;

  @override
  Widget build(BuildContext context, CelebrationFrame frame) =>
      CustomPaint(painter: _CometPainter(frame, landAt, _burst, _trail));
}

class _Spark {
  final Offset jitter;
  final Offset drift;
  final double size;
  final double rotation;
  final Color colour;
  final bool sparkle;

  _Spark(
    this.jitter,
    this.drift,
    this.size,
    this.rotation,
    this.colour,
    this.sparkle,
  );

  factory _Spark.random(Random r, int i) {
    double signed() => r.nextDouble() * 2 - 1;
    return _Spark(
      Offset(signed(), signed()) * 6,
      Offset(signed() * 30, 20 + r.nextDouble() * 40),
      3 + r.nextDouble() * 4,
      r.nextDouble() * pi,
      kCelebrationColours[r.nextInt(kCelebrationColours.length)],
      i.isEven,
    );
  }
}

class _CometPainter extends CustomPainter {
  static const double _life = 0.3;

  final CelebrationFrame frame;
  final double landAt;
  final List<CelebrationParticle> burst;
  final List<_Spark> trail;

  _CometPainter(this.frame, this.landAt, this.burst, this.trail);

  double _headAt(double t) =>
      Curves.easeInOutCubic.transform((t / landAt).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final t = frame.t;
    final flight = frame.flight;
    final head = _headAt(t);

    // Sparks are dropped along the path as the head passes, then drift
    // downwards and fade.
    final paint = Paint();
    for (var i = 0; i < trail.length; i++) {
      final born = landAt * i / trail.length;
      final age = (t - born) / _life;
      if (age <= 0 || age >= 1) continue;
      final spark = trail[i];
      final p =
          flight.pointAt(_headAt(born)) +
          spark.jitter +
          spark.drift * age * _life;
      final r = spark.size * (1 - age);
      paint.color = spark.colour.withValues(alpha: 1 - age);
      spark.sparkle
          ? BurstPainter.drawSparkle(canvas, p, r * 1.6, spark.rotation, paint)
          : canvas.drawCircle(p, r * 0.7, paint);
    }

    if (t < landAt) {
      // A short fading streak behind the head.
      const streak = 12;
      final from = max(0.0, head - 0.16);
      final points = flight.sample(from, head, streak);
      final line =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;
      for (var i = 0; i < streak; i++) {
        final f = (i + 1) / streak;
        line
          ..strokeWidth = 2 + 6 * f
          ..color = const Color(0xFFFFE082).withValues(alpha: 0.7 * f);
        canvas.drawLine(points[i], points[i + 1], line);
      }

      final p = flight.pointAt(head);
      canvas.drawCircle(
        p,
        16,
        Paint()
          ..color = const Color(0xFFFFB300).withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawCircle(p, 6, Paint()..color = Colors.white);
    } else {
      BurstPainter(
        t: frame.phase(landAt, 1),
        center: frame.end,
        particles: burst,
        scale: 0.7,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_CometPainter oldDelegate) => true;
}

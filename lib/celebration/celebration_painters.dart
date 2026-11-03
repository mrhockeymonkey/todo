import 'dart:math';

import 'package:flutter/material.dart';

const List<Color> kCelebrationColours = [
  Color(0xFFFFC107),
  Color(0xFFFF7043),
  Color(0xFF29B6F6),
  Color(0xFF66BB6A),
  Color(0xFFAB47BC),
  Color(0xFFEC407A),
];

/// One piece of a burst or confetti shower.
class CelebrationParticle {
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final double rotation;
  final Color color;
  final bool sparkle;

  CelebrationParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.rotation,
    required this.color,
    required this.sparkle,
  });

  factory CelebrationParticle.random(Random random, int index, int count) =>
      CelebrationParticle(
        angle: 2 * pi * index / count + (random.nextDouble() - 0.5) * 0.4,
        speed: 0.7 + random.nextDouble() * 0.6,
        size: 5 + random.nextDouble() * 5,
        spin: (random.nextDouble() - 0.5) * 20,
        rotation: random.nextDouble() * pi,
        color: kCelebrationColours[random.nextInt(kCelebrationColours.length)],
        sparkle: index.isEven,
      );
}

/// A ring plus a radial spray of dots and four-point sparkles.
class BurstPainter extends CustomPainter {
  final double t;
  final Offset center;
  final List<CelebrationParticle> particles;

  /// Shrinks or grows the whole burst; 1 suits the journey's large nodes.
  final double scale;

  BurstPainter({
    required this.t,
    required this.center,
    required this.particles,
    this.scale = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ease = Curves.easeOutCubic.transform(t);

    final ringT = (t / 0.5).clamp(0.0, 1.0);
    if (ringT < 1) {
      canvas.drawCircle(
        center,
        (40 + 50 * Curves.easeOut.transform(ringT)) * scale,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8 * (1 - ringT) * scale
          ..color = const Color(0xFFFFC107).withValues(alpha: 1 - ringT),
      );
    }

    final paint = Paint();
    for (final p in particles) {
      final distance = (44 + 90 * ease * p.speed) * scale;
      final position = center + Offset(cos(p.angle), sin(p.angle)) * distance;
      final radius = p.size * (1 - t) * scale;
      if (radius <= 0.2) continue;
      paint.color = p.color.withValues(alpha: (1 - t * t).clamp(0.0, 1.0));
      if (p.sparkle) {
        drawSparkle(
          canvas,
          position,
          radius * 1.6,
          p.rotation + p.spin * t * 0.2,
          paint,
        );
      } else {
        canvas.drawCircle(position, radius * 0.7, paint);
      }
    }
  }

  static void drawSparkle(
    Canvas canvas,
    Offset c,
    double r,
    double rotation,
    Paint paint,
  ) {
    final inner = r * 0.3;
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = rotation + i * pi / 4;
      final d = i.isEven ? r : inner;
      final point = c + Offset(cos(a), sin(a)) * d;
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  @override
  bool shouldRepaint(BurstPainter oldDelegate) => oldDelegate.t != t;
}

/// Confetti thrown upwards from the node that tumbles back down under gravity.
class ConfettiPainter extends CustomPainter {
  static const double _gravity = 1500;
  static const double _spread = 1.4;

  final double t;
  final double seconds;
  final Offset center;
  final List<CelebrationParticle> particles;

  /// Scales the launch speed; 1 throws confetti most of the way up a phone
  /// screen.
  final double power;

  ConfettiPainter({
    required this.t,
    required this.seconds,
    required this.center,
    required this.particles,
    this.power = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final time = t * seconds;
    final opacity = t < 0.75 ? 1.0 : 1 - (t - 0.75) / 0.25;
    final paint = Paint();

    for (final p in particles) {
      // Mostly upwards, fanned out by the particle's angle.
      final vx = cos(p.angle) * 320 * p.speed * _spread * power;
      final vy =
          -(520 + 380 * p.speed) *
          power *
          _spread *
          (0.75 + 0.25 * sin(p.angle).abs());
      // A bit of air drag on the horizontal so pieces drift rather than fly.
      final drag = 1 - exp(-time * 2.2);
      final x = center.dx + vx * drag / 2.2;
      final y = center.dy + vy * time + 0.5 * _gravity * time * time;

      paint.color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.spin * time);
      // Squash on one axis to fake the flutter of a flipping piece of paper.
      canvas.scale(cos(time * p.spin.abs() * 1.3), 1);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 1.7,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => oldDelegate.t != t;
}

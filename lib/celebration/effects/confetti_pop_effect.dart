import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/celebration/celebration_effect.dart';
import 'package:todo/celebration/celebration_painters.dart';

/// No path: a confetti shower thrown up from the swiped row while the done
/// item glows gold. A baseline to compare the path effects against.
class ConfettiPopEffect extends CelebrationEffect {
  final List<CelebrationParticle> _particles;

  ConfettiPopEffect(Random random)
    : _particles = List.generate(
        70,
        (i) => CelebrationParticle.random(random, i, 70),
      );

  @override
  Duration get duration => const Duration(milliseconds: 1800);

  @override
  double get landAt => 0.12;

  @override
  Widget build(BuildContext context, CelebrationFrame frame) =>
      CustomPaint(painter: _ConfettiPopPainter(frame, _particles, duration));
}

class _ConfettiPopPainter extends CustomPainter {
  final CelebrationFrame frame;
  final List<CelebrationParticle> particles;
  final Duration duration;

  _ConfettiPopPainter(this.frame, this.particles, this.duration);

  @override
  void paint(Canvas canvas, Size size) {
    final target = frame.target;
    if (target != null) {
      final glow = sin(pi * frame.phase(0.1, 0.6)) * 0.5;
      if (glow > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(target.deflate(4), const Radius.circular(10)),
          Paint()
            ..color = const Color(0xFFFFC107).withValues(alpha: glow)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
    }

    ConfettiPainter(
      t: frame.t,
      seconds: duration.inMilliseconds / 1000,
      center: frame.source.center,
      particles: particles,
      power: 0.6,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(_ConfettiPopPainter oldDelegate) => true;
}

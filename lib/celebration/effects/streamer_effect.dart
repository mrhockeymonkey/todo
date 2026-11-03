import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/celebration/celebration_effect.dart';
import 'package:todo/celebration/celebration_painters.dart';

/// Four thin party streamers fan out from the swipe, loop-the-loop together
/// mid-flight and converge on the done item.
class StreamerEffect extends CelebrationEffect {
  static const int strands = 4;
  final List<CelebrationParticle> _particles;
  final List<Color> _colours;

  StreamerEffect(Random random)
    : _particles = List.generate(
        10,
        (i) => CelebrationParticle.random(random, i, 10),
      ),
      _colours =
          ([...kCelebrationColours]..shuffle(random)).take(strands).toList();

  @override
  Duration get duration => const Duration(milliseconds: 1500);

  @override
  double get landAt => 0.7;

  @override
  Widget build(BuildContext context, CelebrationFrame frame) => CustomPaint(
    painter: _StreamerPainter(frame, landAt, _particles, _colours),
  );
}

class _StreamerPainter extends CustomPainter {
  static const int _samples = 160;
  static const double _loopFrom = 0.5;
  static const double _loopTo = 0.78;
  static const double _stagger = 0.03;

  final CelebrationFrame frame;
  final double landAt;
  final List<CelebrationParticle> particles;
  final List<Color> colours;

  _StreamerPainter(this.frame, this.landAt, this.particles, this.colours);

  @override
  void paint(Canvas canvas, Size size) {
    final t = frame.t;
    final flight = frame.flight;
    // Big enough that the curve doubles back on itself into a real loop.
    final loopRadius = (flight.length * (_loopTo - _loopFrom) / (2 * pi) * 2.2)
        .clamp(18, 50);
    final travel = landAt - _stagger * (colours.length - 1);

    Offset pointAt(double s, int strand) {
      var p = flight.pointAt(s);
      final dir = flight.directionAt(s);
      final normal = Offset(-dir.dy, dir.dx);
      final u = (s - _loopFrom) / (_loopTo - _loopFrom);
      if (u > 0 && u < 1) {
        final a = 2 * pi * u;
        p +=
            dir * (-loopRadius * sin(a)) - normal * (loopRadius * (1 - cos(a)));
      }
      final fan = (strand - (colours.length - 1) / 2) * 7 * (1 - s);
      final wobble = sin(s * 20 + strand * 1.7 - t * 12) * 3 * (1 - s);
      return p + normal * (fan + wobble);
    }

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 3.5;

    for (var k = 0; k < colours.length; k++) {
      final delay = k * _stagger;
      final head = Curves.easeInOutCubic.transform(
        frame.phase(delay, delay + travel),
      );
      final tail = Curves.easeInCubic.transform(
        frame.phase(delay + 0.22, delay + travel + 0.25),
      );
      if (head <= tail) continue;

      final path = Path();
      for (var i = 0; i <= _samples; i++) {
        final p = pointAt(tail + (head - tail) * i / _samples, k);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      paint.color = colours[k];
      canvas.drawPath(path, paint);
    }

    if (t >= landAt) {
      BurstPainter(
        t: frame.phase(landAt, 1),
        center: frame.end,
        particles: particles,
        scale: 0.45,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_StreamerPainter oldDelegate) => true;
}

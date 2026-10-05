import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/journey/journey_provider.dart';

const List<Color> kCelebrationColours = [
  Color(0xFFFFC107),
  Color(0xFFFF7043),
  Color(0xFF29B6F6),
  Color(0xFF66BB6A),
  Color(0xFFAB47BC),
  Color(0xFFEC407A),
];

/// A one-shot celebration drawn over the journey, centred on [center]. It
/// fills its parent (so particles can fly anywhere) and calls [onFinished]
/// once played so the owner can remove it.
class CompletionEffect extends StatefulWidget {
  final JourneyEffect type;
  final Offset center;
  final String label;
  final bool big;
  final VoidCallback onFinished;

  const CompletionEffect({
    super.key,
    required this.type,
    required this.center,
    required this.label,
    required this.onFinished,
    this.big = false,
  });

  @override
  State<CompletionEffect> createState() => _CompletionEffectState();
}

class _CompletionEffectState extends State<CompletionEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  Duration get _duration {
    switch (widget.type) {
      case JourneyEffect.confetti:
        return Duration(milliseconds: widget.big ? 2800 : 2000);
      case JourneyEffect.shockwave:
        return const Duration(milliseconds: 1000);
      case JourneyEffect.burst:
      case JourneyEffect.hold:
        return const Duration(milliseconds: 1100);
    }
  }

  @override
  void initState() {
    super.initState();
    final random = Random();
    final count =
        widget.type == JourneyEffect.confetti ? (widget.big ? 140 : 70) : 16;
    _particles = List.generate(
      count,
      (i) => _Particle.random(random, i, count),
    );
    _controller = AnimationController(vsync: this, duration: _duration)
      ..forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  CustomPainter _painter(double t) {
    switch (widget.type) {
      case JourneyEffect.confetti:
        return _ConfettiPainter(
          t: t,
          seconds: _duration.inMilliseconds / 1000,
          center: widget.center,
          particles: _particles,
          spread: widget.big ? 1.4 : 1.0,
        );
      case JourneyEffect.shockwave:
        return _ShockwavePainter(t: t, center: widget.center);
      case JourneyEffect.burst:
      case JourneyEffect.hold:
        return _BurstPainter(
          t: t,
          center: widget.center,
          particles: _particles,
        );
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final t = _controller.value;
      // The label pops in quickly then drifts up and fades out.
      final labelT = (t / 0.7).clamp(0.0, 1.0);
      final pop = Curves.elasticOut.transform((labelT * 2.5).clamp(0, 1));
      final rise = Curves.easeOut.transform(labelT) * 50;
      final fade = labelT < 0.6 ? 1.0 : 1 - (labelT - 0.6) / 0.4;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: _painter(t))),
          Positioned(
            left: widget.center.dx - 150,
            width: 300,
            top: widget.center.dy - 90 - rise,
            child: Opacity(
              opacity: fade.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: pop,
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.big ? 30 : 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFB300),
                    shadows: const [
                      Shadow(
                        color: Colors.white,
                        blurRadius: 0,
                        offset: Offset(2, 2),
                      ),
                      Shadow(
                        color: Colors.white,
                        blurRadius: 0,
                        offset: Offset(-2, -2),
                      ),
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final double rotation;
  final Color color;
  final bool sparkle;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.rotation,
    required this.color,
    required this.sparkle,
  });

  factory _Particle.random(Random random, int index, int count) => _Particle(
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
class _BurstPainter extends CustomPainter {
  final double t;
  final Offset center;
  final List<_Particle> particles;

  _BurstPainter({
    required this.t,
    required this.center,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ease = Curves.easeOutCubic.transform(t);

    final ringT = (t / 0.5).clamp(0.0, 1.0);
    if (ringT < 1) {
      canvas.drawCircle(
        center,
        40 + 50 * Curves.easeOut.transform(ringT),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8 * (1 - ringT)
          ..color = const Color(0xFFFFC107).withValues(alpha: 1 - ringT),
      );
    }

    final paint = Paint();
    for (final p in particles) {
      final distance = 44 + 90 * ease * p.speed;
      final position = center + Offset(cos(p.angle), sin(p.angle)) * distance;
      final radius = p.size * (1 - t);
      if (radius <= 0.2) continue;
      paint.color = p.color.withValues(alpha: (1 - t * t).clamp(0.0, 1.0));
      if (p.sparkle) {
        _drawSparkle(
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

  static void _drawSparkle(
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
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.t != t;
}

/// Confetti thrown upwards from the node that tumbles back down under gravity.
class _ConfettiPainter extends CustomPainter {
  static const double _gravity = 1500;

  final double t;
  final double seconds;
  final Offset center;
  final List<_Particle> particles;
  final double spread;

  _ConfettiPainter({
    required this.t,
    required this.seconds,
    required this.center,
    required this.particles,
    required this.spread,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final time = t * seconds;
    final opacity = t < 0.75 ? 1.0 : 1 - (t - 0.75) / 0.25;
    final paint = Paint();

    for (final p in particles) {
      // Mostly upwards, fanned out by the particle's angle.
      final vx = cos(p.angle) * 320 * p.speed * spread;
      final vy =
          -(520 + 380 * p.speed) * spread * (0.75 + 0.25 * sin(p.angle).abs());
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
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.t != t;
}

/// A flash and staggered expanding rings, paired with a screen shake by the
/// journey screen.
class _ShockwavePainter extends CustomPainter {
  final double t;
  final Offset center;

  _ShockwavePainter({required this.t, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    final flashT = (t / 0.25).clamp(0.0, 1.0);
    if (flashT < 1) {
      canvas.drawCircle(
        center,
        38 + 40 * flashT,
        Paint()..color = Colors.white.withValues(alpha: 0.8 * (1 - flashT)),
      );
    }

    for (var ring = 0; ring < 3; ring++) {
      final local = ((t - ring * 0.12) / 0.7).clamp(0.0, 1.0);
      if (local <= 0 || local >= 1) continue;
      canvas.drawCircle(
        center,
        38 + 170 * Curves.easeOutCubic.transform(local),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12 * (1 - local)
          ..color = (ring == 1
                  ? const Color(0xFF29B6F6)
                  : const Color(0xFFFFC107))
              .withValues(alpha: 1 - local),
      );
    }
  }

  @override
  bool shouldRepaint(_ShockwavePainter oldDelegate) => oldDelegate.t != t;
}

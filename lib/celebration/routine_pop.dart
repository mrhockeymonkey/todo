import 'dart:math';

import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:provider/provider.dart';
import 'package:todo/celebration/pop_scale.dart';

/// How the routine card celebrates when the last due routine is done.
/// Experimental: the settings page lets you compare them.
enum RoutinePopStyle {
  none("None", "No animation", Duration.zero),
  pop(
    "Pop",
    "Squash-and-stretch, like the journey nodes",
    Duration(milliseconds: 900),
  ),
  splash(
    "Splash",
    "Ripples and droplets thrown up from the card",
    Duration(milliseconds: 1200),
  ),
  bang("Bang", "A flash, shockwave and sparks", Duration(milliseconds: 750));

  final String label;
  final String description;
  final Duration duration;

  const RoutinePopStyle(this.label, this.description, this.duration);
}

/// Remembers the chosen [RoutinePopStyle] in Localstore.
class RoutinePopSettings with ChangeNotifier {
  static const String _collection = "settings";
  static const String _doc = "routinePop";
  static const String _key = "style";

  final bool _persist;
  RoutinePopStyle _style;

  RoutinePopSettings({
    RoutinePopStyle style = RoutinePopStyle.pop,
    bool persist = true,
  }) : _style = style,
       _persist = persist {
    if (_persist) _load();
  }

  RoutinePopStyle get style => _style;

  set style(RoutinePopStyle value) {
    _style = value;
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    if (!_persist) return;
    await Localstore.instance.collection(_collection).doc(_doc).set({
      _key: _style.name,
    });
  }

  Future<void> _load() async {
    try {
      final data =
          await Localstore.instance.collection(_collection).doc(_doc).get();
      final name = data?[_key];
      final match = RoutinePopStyle.values.where((s) => s.name == name);
      if (match.isEmpty) return;
      _style = match.first;
      notifyListeners();
    } catch (e) {
      debugPrint("Could not load routine pop setting: $e");
    }
  }
}

/// Wraps a card so it can play the chosen [RoutinePopStyle] on demand: call
/// [RoutinePopStageState.play] through a key. The effect is drawn over and
/// around the child without affecting layout or touches.
class RoutinePopStage extends StatefulWidget {
  final Widget child;

  const RoutinePopStage({super.key, required this.child});

  @override
  State<RoutinePopStage> createState() => RoutinePopStageState();
}

class RoutinePopStageState extends State<RoutinePopStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  RoutinePopStyle _playing = RoutinePopStyle.none;
  List<_Particle> _particles = const [];

  /// Plays the style currently chosen in [RoutinePopSettings]; completes when
  /// it has finished (straight away for none).
  Future<void> play() async {
    final style = context.read<RoutinePopSettings>().style;
    if (style == RoutinePopStyle.none) return;
    final random = Random();
    setState(() {
      _playing = style;
      _particles = switch (style) {
        RoutinePopStyle.splash => List.generate(
          22,
          (i) => _Particle.droplet(random),
        ),
        RoutinePopStyle.bang => List.generate(
          24,
          (i) => _Particle.spark(random, i, 24),
        ),
        _ => const [],
      };
    });
    _controller.duration = style.duration;
    await _controller.forward(from: 0).orCancel.catchError((_) {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      if (!_controller.isAnimating) return child!;
      final t = _controller.value;
      final (scale, dx) = _cardTransform(t);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: Offset(dx, 0),
            child: Transform.scale(scale: scale, child: child),
          ),
          if (_playing == RoutinePopStyle.splash ||
              _playing == RoutinePopStyle.bang)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  key: const ValueKey("routine-pop-effect"),
                  painter:
                      _playing == RoutinePopStyle.splash
                          ? _SplashPainter(t, _particles)
                          : _BangPainter(t, _particles),
                ),
              ),
            ),
        ],
      );
    },
  );

  (double scale, double dx) _cardTransform(double t) => switch (_playing) {
    RoutinePopStyle.pop => (popScale.transform(t), 0.0),
    // A little dip as if something dropped in, then settle.
    RoutinePopStyle.splash => (
      1 - 0.05 * sin(min(t / 0.35, 1) * pi) * (1 - t),
      0.0,
    ),
    // A hard kick and a shudder.
    RoutinePopStyle.bang => (
      1 + 0.12 * sin(min(t / 0.3, 1) * pi),
      sin(t * pi * 12) * 8 * (1 - t) * (1 - t),
    ),
    RoutinePopStyle.none => (1.0, 0.0),
  };
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color colour;

  const _Particle(this.angle, this.speed, this.size, this.colour);

  static const _water = [
    Color(0xFF29B6F6),
    Color(0xFF4FC3F7),
    Color(0xFF0288D1),
    Color(0xFFB3E5FC),
  ];
  static const _fire = [
    Color(0xFFFFEB3B),
    Color(0xFFFFC107),
    Color(0xFFFF7043),
    Color(0xFFF44336),
  ];

  /// Thrown up in a fan.
  factory _Particle.droplet(Random r) => _Particle(
    -pi / 2 + (r.nextDouble() - 0.5) * 2.2,
    350 + r.nextDouble() * 350,
    3 + r.nextDouble() * 4,
    _water[r.nextInt(_water.length)],
  );

  /// Flies out evenly all round.
  factory _Particle.spark(Random r, int i, int n) => _Particle(
    2 * pi * i / n + (r.nextDouble() - 0.5) * 0.3,
    0.6 + r.nextDouble() * 0.6,
    3 + r.nextDouble() * 2,
    _fire[r.nextInt(_fire.length)],
  );
}

/// Elliptical ripples on the card plus droplets arcing up and falling back.
class _SplashPainter extends CustomPainter {
  static const double _gravity = 1500;

  final double t;
  final List<_Particle> particles;

  _SplashPainter(this.t, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);

    for (final delay in const [0.0, 0.14]) {
      final rt = ((t - delay) / 0.6).clamp(0.0, 1.0);
      if (rt <= 0 || rt >= 1) continue;
      final radius = 20 + size.width * 0.45 * Curves.easeOutCubic.transform(rt);
      canvas.drawOval(
        Rect.fromCenter(center: c, width: radius * 2, height: radius * 0.7),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 * (1 - rt)
          ..color = const Color(0xFF29B6F6).withValues(alpha: 1 - rt),
      );
    }

    final seconds = t * 1.2;
    final fade = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;
    final paint = Paint();
    for (final p in particles) {
      final x = c.dx + cos(p.angle) * p.speed * seconds * 0.6;
      final y =
          c.dy +
          sin(p.angle) * p.speed * seconds +
          0.5 * _gravity * seconds * seconds;
      paint.color = p.colour.withValues(alpha: fade.clamp(0.0, 1.0));
      // Stretch each drop along its direction of travel.
      final vy = sin(p.angle) * p.speed + _gravity * seconds;
      final vx = cos(p.angle) * p.speed * 0.6;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(atan2(vy, vx) - pi / 2);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size * 2,
          height: p.size * 3.2,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SplashPainter old) => old.t != t;
}

/// A white-hot flash, a jagged starburst, a shockwave and streaking sparks.
class _BangPainter extends CustomPainter {
  final double t;
  final List<_Particle> particles;

  _BangPainter(this.t, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);

    final flashT = (t / 0.3).clamp(0.0, 1.0);
    if (flashT < 1) {
      final radius = 30 + 120 * Curves.easeOut.transform(flashT);
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 1 - flashT),
              const Color(0xFFFFEB3B).withValues(alpha: 0.8 * (1 - flashT)),
              const Color(0xFFFF7043).withValues(alpha: 0),
            ],
            stops: const [0, 0.5, 1],
          ).createShader(Rect.fromCircle(center: c, radius: radius)),
      );
    }

    final starT = (t / 0.5).clamp(0.0, 1.0);
    if (starT < 1) {
      final outer = 25 + 80 * Curves.easeOutCubic.transform(starT);
      final alpha = (1 - starT).clamp(0.0, 1.0);
      _star(canvas, c, outer, 14, const Color(0xFFFF7043), alpha);
      _star(canvas, c, outer * 0.6, 14, const Color(0xFFFFEB3B), alpha);
    }

    final waveT = (t / 0.8).clamp(0.0, 1.0);
    if (waveT < 1) {
      canvas.drawCircle(
        c,
        20 + size.width * 0.5 * Curves.easeOutQuart.transform(waveT),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7 * (1 - waveT)
          ..color = const Color(0xFFFFC107).withValues(alpha: 1 - waveT),
      );
    }

    final move = Curves.easeOutCubic.transform(t);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    for (final p in particles) {
      final dir = Offset(cos(p.angle), sin(p.angle));
      final head = c + dir * (30 + 220 * move * p.speed);
      final tail = head - dir * (26 * p.speed * (1 - t));
      paint
        ..strokeWidth = p.size * (1 - t * 0.7)
        ..color = p.colour.withValues(alpha: (1 - t * t).clamp(0.0, 1.0));
      canvas.drawLine(tail, head, paint);
    }
  }

  static void _star(
    Canvas canvas,
    Offset c,
    double outer,
    int points,
    Color colour,
    double alpha,
  ) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final a = i * pi / points;
      final d = i.isEven ? outer : outer * 0.55;
      final p = c + Offset(cos(a), sin(a)) * d;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path..close(),
      Paint()..color = colour.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(_BangPainter old) => old.t != t;
}

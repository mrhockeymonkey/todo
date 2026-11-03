import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/celebration/celebration_painters.dart';

/// A one-shot celebration drawn over the journey, centred on [center]: a
/// sparkle burst for a step, or a confetti shower for the [finale]. It fills
/// its parent (so particles can fly anywhere) and calls [onFinished] once
/// played so the owner can remove it.
class CompletionEffect extends StatefulWidget {
  final Offset center;
  final String label;
  final bool finale;
  final VoidCallback onFinished;

  const CompletionEffect({
    super.key,
    required this.center,
    required this.label,
    required this.onFinished,
    this.finale = false,
  });

  @override
  State<CompletionEffect> createState() => _CompletionEffectState();
}

class _CompletionEffectState extends State<CompletionEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<CelebrationParticle> _particles;

  Duration get _duration =>
      widget.finale
          ? const Duration(milliseconds: 2800)
          : const Duration(milliseconds: 1100);

  @override
  void initState() {
    super.initState();
    final random = Random();
    final count = widget.finale ? 140 : 16;
    _particles = List.generate(
      count,
      (i) => CelebrationParticle.random(random, i, count),
    );
    _controller = AnimationController(vsync: this, duration: _duration)
      ..forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  CustomPainter _painter(double t) =>
      widget.finale
          ? ConfettiPainter(
            t: t,
            seconds: _duration.inMilliseconds / 1000,
            center: widget.center,
            particles: _particles,
          )
          : BurstPainter(t: t, center: widget.center, particles: _particles);

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
                    fontSize: widget.finale ? 30 : 24,
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

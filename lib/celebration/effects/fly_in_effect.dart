import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/celebration/celebration_effect.dart';

/// The task itself lifts off as a coloured pill, hops along an arc leaving a
/// rainbow dotted trail, and squashes down into the done item.
class FlyInEffect extends CelebrationEffect {
  final CelebrationRequest request;

  FlyInEffect(this.request);

  @override
  Duration get duration => const Duration(milliseconds: 1200);

  @override
  double get landAt => 0.75;

  /// Lift off from the middle of where the row was, so the hop arcs across
  /// into the done item rather than dropping straight down.
  @override
  Offset launchPoint(Rect source) =>
      Offset(source.left + source.width * 0.45, source.center.dy);

  @override
  Widget build(BuildContext context, CelebrationFrame frame) {
    final travel = Curves.easeInOutCubic.transform(frame.phase(0, landAt));
    final land = frame.phase(landAt, 1);
    final flight = frame.flight;
    final p = flight.pointAt(travel);

    // Shrink in flight, tilting with the direction of travel.
    final dir = flight.directionAt(travel);
    final tilt = land > 0 ? 0.0 : atan2(dir.dy, dir.dx).clamp(-1.2, 1.2) * 0.08;
    final squash = sin(pi * land) * 0.18;
    final scale = 1 - 0.3 * Curves.easeOut.transform(frame.phase(0, 0.4));
    final opacity = 1 - Curves.easeIn.transform(land);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _TrailPainter(frame, travel)),
        ),
        Positioned(
          // Keep the pill's leading check on the path.
          left: p.dx - 18,
          top: p.dy,
          child: FractionalTranslation(
            translation: const Offset(0, -0.5),
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform(
                alignment: Alignment.centerLeft,
                transform:
                    Matrix4.identity()
                      ..rotateZ(tilt)
                      ..scaleByDouble(
                        scale * (1 + squash),
                        scale * (1 - squash),
                        1,
                        1,
                      ),
                child: _buildPill(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPill() => Material(
    color: request.colour,
    elevation: 6,
    borderRadius: BorderRadius.circular(20),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                request.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TrailPainter extends CustomPainter {
  static const int _dots = 22;
  static const double _length = 0.45;

  final CelebrationFrame frame;
  final double travel;

  _TrailPainter(this.frame, this.travel);

  @override
  void paint(Canvas canvas, Size size) {
    final fade = 1 - frame.phase(0.75, 1);
    final paint = Paint();
    for (var i = 0; i < _dots; i++) {
      final s = i / _dots;
      if (s > travel) break;
      final behind = (travel - s) / _length;
      if (behind >= 1) continue;
      paint.color = rainbow(360 * s, alpha: (1 - behind) * fade);
      canvas.drawCircle(
        frame.flight.pointAt(s),
        3.5 * (1 - behind * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) => true;
}

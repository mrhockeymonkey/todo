import 'package:flutter/material.dart';
import 'package:todo/app_colour.dart';

/// The animated session circle: a soft glow halo, a disc that grows with
/// [fill] (0 = relaxed, 1 = fully contracted) and a white core. The
/// countdown text is laid over the top by the caller.
class KegelCircle extends StatelessWidget {
  final double fill;
  final double diameter;

  const KegelCircle({
    super.key,
    required this.fill,
    required this.diameter,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(diameter),
      painter: KegelCirclePainter(fill: fill),
    );
  }
}

class KegelCirclePainter extends CustomPainter {
  /// Core (white circle) radius as a fraction of the maximum radius.
  static const double _coreFraction = 0.38;

  final double fill;

  KegelCirclePainter({required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final coreRadius = maxRadius * _coreFraction;
    final discRadius = coreRadius + fill * (maxRadius - coreRadius - 12);

    // Glow halo around the disc.
    canvas.drawCircle(
        center,
        discRadius + 12,
        Paint()
          ..color = AppColour.colorCustom.withValues(alpha: 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24));

    // The animated disc.
    canvas.drawCircle(
        center,
        discRadius,
        Paint()
          ..color = Color.lerp(AppColour.colorCustom.withValues(alpha: 0.45),
              AppColour.colorCustom, fill)!);

    // White core with a subtle outline.
    canvas.drawCircle(center, coreRadius, Paint()..color = Colors.white);
    canvas.drawCircle(
        center,
        coreRadius,
        Paint()
          ..color = AppColour.colorCustom.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(KegelCirclePainter oldDelegate) =>
      oldDelegate.fill != fill;
}

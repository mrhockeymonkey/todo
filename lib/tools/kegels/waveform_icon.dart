import 'package:flutter/material.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/tools/kegels/kegel_pattern.dart';

/// Draws a small trace of a pattern's rep envelope (rise over contract,
/// flat top for hold, fall over relax, flat bottom for wait).
class WaveformIcon extends StatelessWidget {
  final KegelPattern pattern;
  final double width;
  final double height;

  const WaveformIcon({
    super.key,
    required this.pattern,
    this.width = 40,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _WaveformPainter(pattern),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  static const int _repsToDraw = 3;

  final KegelPattern pattern;

  _WaveformPainter(this.pattern);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColour.colorCustom
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final reps = pattern.reps < _repsToDraw ? pattern.reps : _repsToDraw;
    final repWidth = size.width / reps;
    final top = paint.strokeWidth / 2;
    final bottom = size.height - paint.strokeWidth / 2;

    final path = Path()..moveTo(0, bottom);
    for (var rep = 0; rep < reps; rep++) {
      final start = rep * repWidth;
      var x = start;
      for (final (seconds, y) in [
        (pattern.contractSeconds, top),
        (pattern.holdSeconds, top),
        (pattern.relaxSeconds, bottom),
        (pattern.waitSeconds, bottom),
      ]) {
        x += repWidth * seconds / pattern.repSeconds;
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.pattern != pattern;
}

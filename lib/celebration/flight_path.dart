import 'dart:math';
import 'dart:ui';

/// The curve a celebration travels along: it leaves where the swipe threw the
/// task off the right of the row, arcs up and over, and swoops down into the
/// leading icon of the done item.
class FlightPath {
  final Offset start;
  final Offset end;
  late final Path path;
  late final PathMetric _metric;

  FlightPath(this.start, this.end) {
    // Arc height grows with the distance travelled so short hops still loop
    // up a little and long ones don't fly off the top of the screen.
    final lift = 70 + 0.25 * (end - start).distance.clamp(0, 600);
    final c1 = start + Offset(24, -lift);
    final c2 = end + Offset(-36, -lift * 0.9);
    path =
        Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    _metric = path.computeMetrics().first;
  }

  double get length => _metric.length;

  /// Position at [s] (0 = start, 1 = end) along the path's length.
  Offset pointAt(double s) =>
      _metric.getTangentForOffset(length * s.clamp(0.0, 1.0))?.position ?? end;

  /// Unit direction of travel at [s].
  Offset directionAt(double s) {
    final v =
        _metric.getTangentForOffset(length * s.clamp(0.0, 1.0))?.vector ??
        const Offset(1, 0);
    final d = v.distance;
    return d == 0 ? const Offset(1, 0) : v / d;
  }

  /// Unit normal (direction rotated 90°) at [s].
  Offset normalAt(double s) {
    final d = directionAt(s);
    return Offset(-d.dy, d.dx);
  }

  /// The section of the path between [from] and [to].
  Path extract(double from, double to) {
    final a = from.clamp(0.0, 1.0), b = to.clamp(0.0, 1.0);
    if (b <= a) return Path();
    return _metric.extractPath(length * a, length * b);
  }

  /// [count] + 1 evenly spaced points between [from] and [to].
  List<Offset> sample(double from, double to, int count) => [
    for (var i = 0; i <= count; i++)
      pointAt(from + (to - from) * i / max(count, 1)),
  ];
}

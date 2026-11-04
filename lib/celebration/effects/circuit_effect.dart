import 'dart:math';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:todo/celebration/celebration_effect.dart';

/// Which section of the settings screen a [CircuitParam] appears in.
enum CircuitGroup {
  main("Main line"),
  followers("Followers"),
  gravity("Gravity");

  final String label;

  const CircuitGroup(this.label);
}

/// Every tunable of [CircuitEffect]. The settings screen builds a slider for
/// each and [CelebrationSettings] saves each, so adding one here is enough
/// to make it adjustable.
enum CircuitParam {
  thickness(
    "Thickness",
    CircuitGroup.main,
    min: 1,
    max: 20,
    initial: 4,
    divisions: 38,
    unit: "px",
    decimals: 1,
  ),
  speed(
    "Speed",
    CircuitGroup.main,
    min: 200,
    max: 3000,
    initial: 900,
    divisions: 56,
    unit: "px/s",
  ),
  length(
    "Length",
    CircuitGroup.main,
    min: 40,
    max: 400,
    initial: 160,
    divisions: 36,
    unit: "px",
  ),
  followers(
    "Lines",
    CircuitGroup.followers,
    min: 0,
    max: 6,
    initial: 3,
    divisions: 6,
  ),
  followerDelay(
    "Delay",
    CircuitGroup.followers,
    min: 0,
    max: 200,
    initial: 45,
    divisions: 40,
    unit: "ms",
  ),
  followerOffset(
    "Side gap",
    CircuitGroup.followers,
    min: 0,
    max: 20,
    initial: 6,
    divisions: 40,
    unit: "px",
    decimals: 1,
  ),
  followerThickness(
    "Thickness",
    CircuitGroup.followers,
    min: 30,
    max: 100,
    initial: 75,
    divisions: 14,
    unit: "%",
  ),
  shadeSpread(
    "Shades",
    CircuitGroup.followers,
    min: 0,
    max: 100,
    initial: 50,
    divisions: 20,
    unit: "%",
  ),
  gravity(
    "Gravity",
    CircuitGroup.gravity,
    min: 0,
    max: 8000,
    initial: 2500,
    divisions: 80,
    unit: "px/s²",
  ),
  minSpeed(
    "Min speed",
    CircuitGroup.gravity,
    min: 50,
    max: 1000,
    initial: 200,
    divisions: 19,
    unit: "px/s",
  );

  final String label;
  final CircuitGroup group;
  final double min;
  final double max;
  final double initial;
  final int divisions;
  final String unit;
  final int decimals;

  const CircuitParam(
    this.label,
    this.group, {
    required this.min,
    required this.max,
    required this.initial,
    required this.divisions,
    this.unit = "",
    this.decimals = 0,
  });

  /// Key used to save the value, e.g. `circuitThickness`.
  String get storageKey =>
      "circuit${name[0].toUpperCase()}${name.substring(1)}";

  String format(double value) =>
      "${value.toStringAsFixed(decimals)}${unit.isEmpty ? "" : " $unit"}";
}

/// Values for every [CircuitParam]; anything not set uses its default.
class CircuitOptions {
  final Map<CircuitParam, double> _values;

  const CircuitOptions() : _values = const {};

  CircuitOptions._(this._values);

  /// Convenience for tests and code that only cares about a few values.
  factory CircuitOptions.of(Map<CircuitParam, double> values) =>
      values.entries.fold(
        const CircuitOptions(),
        (options, e) => options.withValue(e.key, e.value),
      );

  double operator [](CircuitParam param) => _values[param] ?? param.initial;

  CircuitOptions withValue(CircuitParam param, double value) =>
      CircuitOptions._({
        ..._values,
        param: value.clamp(param.min, param.max).toDouble(),
      });

  double get thickness => this[CircuitParam.thickness];
  double get speed => this[CircuitParam.speed];
  double get length => this[CircuitParam.length];
  int get followers => this[CircuitParam.followers].round();
  double get followerDelay => this[CircuitParam.followerDelay] / 1000;
  double get followerOffset => this[CircuitParam.followerOffset];
  double get followerThickness =>
      thickness * this[CircuitParam.followerThickness] / 100;
  double get shadeSpread => this[CircuitParam.shadeSpread] / 100;
  double get gravity => this[CircuitParam.gravity];
  double get minSpeed => this[CircuitParam.minSpeed];
}

/// A solid red line that starts where the swiped tile was thrown to (its
/// right-hand side), runs left along the row to the middle of the screen,
/// loops the loop (a 270° turn) and drops straight down into the done item,
/// as if the task rode the line there.
///
/// Followers in other shades of red run the same route a little behind,
/// optionally to either side. With gravity the lines slow as they climb into
/// the loop and speed up as they drop, like a rollercoaster.
class CircuitEffect extends CelebrationEffect {
  static const Color colour = Colors.red;
  static const double loopRadius = 36;
  static const Duration _giveUpAfter = Duration(seconds: 3);

  final CircuitOptions options;

  CircuitEffect([this.options = const CircuitOptions()]);

  /// An upper bound; the effect ends as soon as the last line has run in.
  @override
  Duration get duration => const Duration(seconds: 10);

  @override
  double get landAt => 1;

  @override
  Offset launchPoint(Rect source) =>
      Offset(source.right - 16, source.center.dy);

  CelebrationFrame? _cachedFrame;
  CircuitMotion? _cachedRun;

  /// The route and motion for [frame], worked out once per frame.
  CircuitMotion _run(CelebrationFrame frame) {
    if (identical(frame, _cachedFrame)) return _cachedRun!;
    final spread = options.followers > 0 ? options.followerOffset : 0.0;
    final widest =
        options.thickness / 2 + spread * ((options.followers + 1) ~/ 2);
    final route = circuitRoute(
      start: frame.start,
      endY: frame.end.dy,
      width: frame.size.width,
      top: frame.contentTop + 8 + widest,
      radius: loopRadius + widest,
    );
    _cachedFrame = frame;
    return _cachedRun = CircuitMotion(route, options);
  }

  double _seconds(CelebrationFrame frame) => frame.elapsed.inMicroseconds / 1e6;

  /// Only lands once the done item exists; until then the route ends at a
  /// guess, which a fast line could otherwise reach first.
  @override
  bool hasLanded(CelebrationFrame frame) {
    if (frame.target == null) return false;
    final run = _run(frame);
    return run.distanceAt(_seconds(frame)) >= run.length;
  }

  @override
  bool isFinished(CelebrationFrame frame) {
    // Give up if the done item never turns up.
    if (frame.target == null) return frame.elapsed > _giveUpAfter;
    final run = _run(frame);
    final last = _seconds(frame) - options.followers * options.followerDelay;
    return run.distanceAt(last) - options.length >= run.length;
  }

  @override
  Widget build(BuildContext context, CelebrationFrame frame) {
    final run = _run(frame);
    final seconds = _seconds(frame);
    final lines = <_Line>[
      for (var i = 0; i <= options.followers; i++)
        _line(run, i, run.distanceAt(seconds - i * options.followerDelay)),
    ];
    // Followers underneath, the leader on top.
    return CustomPaint(
      painter: _CircuitPainter(run.metric, lines.reversed.toList()),
    );
  }

  /// Line [index] (0 is the leader) with its head at [head] along the route.
  _Line _line(CircuitMotion run, int index, double head) {
    final from = max(0.0, head - options.length);
    final to = min(run.length, head);
    if (index == 0) {
      return _Line(from, to, 0, options.thickness, colour);
    }
    // Followers alternate sides and shades: 1 right and lighter, 2 left and
    // darker, 3 further right and lighter still, ...
    final rank = (index + 1) ~/ 2;
    final side = index.isOdd ? 1 : -1;
    final ranks = (options.followers + 1) ~/ 2;
    final shift = options.shadeSpread * 0.3 * rank / ranks;
    final hsl = HSLColor.fromColor(colour);
    final shade = hsl.withLightness(
      (hsl.lightness + side * shift).clamp(0.15, 0.9),
    );
    return _Line(
      from,
      to,
      side * rank * options.followerOffset,
      options.followerThickness,
      shade.toColor(),
    );
  }
}

/// The route plus how far along it a line is after a given time.
///
/// Without gravity a line moves at a constant speed. With it, the speed at
/// each point follows energy conservation, v² = v₀² + 2g·(drop since the
/// start), never going below the minimum speed: slowest at the top of the
/// loop, fastest at the bottom of the drop.
class CircuitMotion {
  static const double _step = 2;

  final PathMetric metric;
  final double length;
  final CircuitOptions options;

  /// Seconds taken to reach each [_step] pixels along the route.
  late final List<double> _times;

  CircuitMotion(Path route, this.options)
    : metric = route.computeMetrics().first,
      length = route.computeMetrics().first.length {
    final startY = metric.getTangentForOffset(0)!.position.dy;
    final steps = (length / _step).ceil();
    final times = List<double>.filled(steps + 1, 0);
    for (var i = 1; i <= steps; i++) {
      final s = min(length, (i - 0.5) * _step);
      final y = metric.getTangentForOffset(s)!.position.dy;
      times[i] = times[i - 1] + _step / _speedAt(y - startY);
    }
    _times = times;
  }

  double _speedAt(double drop) {
    final v0 = options.speed;
    final v2 = v0 * v0 + 2 * options.gravity * drop;
    return max(options.minSpeed, sqrt(max(0, v2)));
  }

  double get _endSpeed {
    final endY = metric.getTangentForOffset(length)!.position.dy;
    final startY = metric.getTangentForOffset(0)!.position.dy;
    return _speedAt(endY - startY);
  }

  /// Distance along the route after [seconds]. Negative before the start;
  /// past [length] after the end, carrying on at the final speed, so a
  /// line's tail can run in after its head.
  double distanceAt(double seconds) {
    if (seconds <= 0) return seconds * options.speed;
    final total = _times.last;
    if (seconds >= total) return length + (seconds - total) * _endSpeed;

    var lo = 0, hi = _times.length - 1;
    while (hi - lo > 1) {
      final mid = (lo + hi) >> 1;
      _times[mid] <= seconds ? lo = mid : hi = mid;
    }
    final f = (seconds - _times[lo]) / (_times[hi] - _times[lo]);
    return min(length, (lo + f) * _step);
  }
}

/// The route described on [CircuitEffect]: from [start] left to the middle
/// of the screen, a 270° loop, then straight to [endY]. The loop goes up and
/// over when the done item is below, and down and under when it is above,
/// and is shrunk if needed to stay below [top].
Path circuitRoute({
  required Offset start,
  required double endY,
  required double width,
  required double top,
  double radius = 36,
}) {
  final mid = width / 2;
  final y = start.dy;
  final goingDown = endY >= y - radius;
  // Keep an upward loop clear of the app bar.
  final r = goingDown ? max(8.0, min(radius, (y - top) / 2)) : radius;
  // The loop's centre sits so the line leaves it heading straight down (or
  // up) along the middle of the screen.
  final centre = Offset(mid - r, goingDown ? y - r : y + r);
  final startX = max(start.dx, centre.dx + 1);

  return Path()
    ..moveTo(startX, y)
    ..lineTo(centre.dx, y)
    // Clockwise from the bottom of the circle round to its right-hand side
    // (or anticlockwise from the top, when heading up).
    ..arcTo(
      Rect.fromCircle(center: centre, radius: r),
      goingDown ? pi / 2 : -pi / 2,
      goingDown ? 3 * pi / 2 : -3 * pi / 2,
      false,
    )
    ..lineTo(mid, endY);
}

/// One line to draw: the stretch [from]–[to] of the route, shifted [side]
/// pixels to the right of the direction of travel.
class _Line {
  final double from;
  final double to;
  final double side;
  final double thickness;
  final Color colour;

  const _Line(this.from, this.to, this.side, this.thickness, this.colour);
}

class _CircuitPainter extends CustomPainter {
  static const double _sample = 3;

  final PathMetric metric;
  final List<_Line> lines;

  _CircuitPainter(this.metric, this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    for (final line in lines) {
      if (line.to <= line.from) continue;
      paint
        ..strokeWidth = line.thickness
        ..color = line.colour;
      canvas.drawPath(_pathFor(line), paint);
    }
  }

  Path _pathFor(_Line line) {
    if (line.side == 0) return metric.extractPath(line.from, line.to);
    // Offset sideways along the normal, sampling the route.
    final path = Path();
    final count = max(1, ((line.to - line.from) / _sample).ceil());
    for (var i = 0; i <= count; i++) {
      final s = line.from + (line.to - line.from) * i / count;
      final tangent = metric.getTangentForOffset(s)!;
      final v = tangent.vector;
      final p = tangent.position + Offset(-v.dy, v.dx) * line.side;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_CircuitPainter oldDelegate) => true;
}

import 'dart:async';

class GaugeDriver {
  final StreamController _controller;
  double _current = 0.0;

  GaugeDriver() : _controller = StreamController.broadcast();

  bool get maxed => (_current > 0.99);

  void listen(Function(dynamic)? x) => _controller.stream.listen(x);

  void drive(double x) {
    _current = maxed ? 0 : (_current + x);
    _controller.add(_current);
  }
}

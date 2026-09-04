import 'dart:async';

import 'package:vibration/vibration.dart';

/// Vibrates the phone in proportion to how full the contraction is.
///
/// Polls [fillGetter] every 100ms and fires overlapping 130ms pulses whose
/// amplitude tracks the fill, which feels continuous without spamming the
/// platform channel. Devices without amplitude control get a fixed buzz
/// only in the upper half of the contraction.
class VibrationDriver {
  final double Function() fillGetter;
  final bool Function() isActive;

  bool enabled = true;
  bool _hasVibrator = false;
  bool _hasAmplitude = false;
  Timer? _timer;

  VibrationDriver({required this.fillGetter, required this.isActive});

  Future<void> init() async {
    _hasVibrator = await Vibration.hasVibrator();
    _hasAmplitude = await Vibration.hasAmplitudeControl();
    if (_hasVibrator) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), _tick);
    }
  }

  void _tick(Timer timer) {
    if (!enabled || !isActive()) return;
    final fill = fillGetter();
    if (fill < 0.05) return;
    if (_hasAmplitude) {
      Vibration.vibrate(duration: 130, amplitude: (1 + fill * 254).round());
    } else if (fill >= 0.5) {
      Vibration.vibrate(duration: 60);
    }
  }

  void stop() {
    if (_hasVibrator) Vibration.cancel();
  }

  void dispose() {
    _timer?.cancel();
    stop();
  }
}

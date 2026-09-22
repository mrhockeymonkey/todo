import 'dart:async';

import 'package:vibration/vibration.dart';

/// Constant knock rate: how many vibration pulses fire per second.
const double kVibrationBeatsPerSecond = 8;

/// Duration of each individual knock pulse, in ms. Kept well under the beat
/// period so there's a felt gap between knocks rather than one long buzz.
const int kVibrationPulseMs = 60;

/// Vibrates the phone in a steady "knocking" pattern while contracting.
///
/// Fires a short [kVibrationPulseMs] pulse every beat (at
/// [kVibrationBeatsPerSecond]), polling [fillGetter] each beat so only the
/// pulse *amplitude* tracks the fill — the cadence itself stays constant.
/// Devices without amplitude control still knock at the same cadence, but
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
      final beatPeriod = Duration(
        milliseconds: (1000 / kVibrationBeatsPerSecond).round(),
      );
      _timer = Timer.periodic(beatPeriod, _tick);
    }
  }

  void _tick(Timer timer) {
    if (!enabled || !isActive()) return;
    final fill = fillGetter();
    if (fill < 0.05) return;
    if (_hasAmplitude) {
      Vibration.vibrate(
        duration: kVibrationPulseMs,
        amplitude: (1 + fill * 254).round(),
      );
    } else if (fill >= 0.5) {
      Vibration.vibrate(duration: kVibrationPulseMs);
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

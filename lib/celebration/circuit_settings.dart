import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';

/// Which section of the settings screen a [CircuitParam] appears in.
enum CircuitGroup {
  main("Main line"),
  followers("Followers"),
  gravity("Gravity");

  final String label;

  const CircuitGroup(this.label);
}

/// Every tunable of the completion animation. The settings screen builds a
/// slider for each and [CircuitSettings] saves each, so adding one here is
/// enough to make it adjustable.
enum CircuitParam {
  thickness(
    "Thickness",
    CircuitGroup.main,
    min: 1,
    max: 20,
    initial: 16,
    divisions: 38,
    unit: "px",
    decimals: 1,
  ),
  speed(
    "Speed",
    CircuitGroup.main,
    min: 200,
    max: 3000,
    initial: 1200,
    divisions: 56,
    unit: "px/s",
  ),
  length(
    "Length",
    CircuitGroup.main,
    min: 40,
    max: 400,
    initial: 300,
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
    initial: 10,
    divisions: 40,
    unit: "px",
    decimals: 1,
  ),
  followerThickness(
    "Thickness",
    CircuitGroup.followers,
    min: 30,
    max: 100,
    initial: 40,
    divisions: 14,
    unit: "%",
  ),
  shadeSpread(
    "Shades",
    CircuitGroup.followers,
    min: 0,
    max: 100,
    initial: 90,
    divisions: 20,
    unit: "%",
  ),
  gravity(
    "Gravity",
    CircuitGroup.gravity,
    min: 0,
    max: 8000,
    initial: 4500,
    divisions: 80,
    unit: "px/s²",
  ),
  minSpeed(
    "Min speed",
    CircuitGroup.gravity,
    min: 50,
    max: 1000,
    initial: 50,
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

  /// Options with just [values] changed from the defaults.
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

  /// In seconds.
  double get followerDelay => this[CircuitParam.followerDelay] / 1000;
  double get followerOffset => this[CircuitParam.followerOffset];

  /// In pixels.
  double get followerThickness =>
      thickness * this[CircuitParam.followerThickness] / 100;

  /// 0 to 1.
  double get shadeSpread => this[CircuitParam.shadeSpread] / 100;
  double get gravity => this[CircuitParam.gravity];
  double get minSpeed => this[CircuitParam.minSpeed];
}

/// Remembers the [CircuitOptions] in Localstore.
class CircuitSettings with ChangeNotifier {
  static const String _collection = "settings";
  static const String _doc = "celebration";

  final bool _persist;
  CircuitOptions _options;

  CircuitSettings({
    CircuitOptions options = const CircuitOptions(),
    bool persist = true,
  }) : _options = options,
       _persist = persist {
    if (_persist) _load();
  }

  CircuitOptions get options => _options;

  /// Updates the options in memory; call [save] to keep them (e.g. when a
  /// slider is let go, rather than on every step of the drag).
  set options(CircuitOptions value) {
    _options = value;
    notifyListeners();
  }

  Future<void> save() async {
    if (!_persist) return;
    await Localstore.instance.collection(_collection).doc(_doc).set({
      for (final param in CircuitParam.values)
        param.storageKey: _options[param],
    });
  }

  Future<void> _load() async {
    try {
      final data =
          await Localstore.instance.collection(_collection).doc(_doc).get();
      if (data == null) return;
      for (final param in CircuitParam.values) {
        final value = data[param.storageKey];
        if (value is num) {
          _options = _options.withValue(param, value.toDouble());
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Could not load completion animation settings: $e");
    }
  }
}

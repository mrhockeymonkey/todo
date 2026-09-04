import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/tools/kegels/kegel_circle.dart';
import 'package:todo/tools/kegels/kegel_pattern.dart';
import 'package:todo/tools/kegels/kegel_session_engine.dart';
import 'package:todo/tools/kegels/vibration_driver.dart';

class KegelSessionScreen extends StatefulWidget {
  static const String routeName = '/tools/kegels/session';

  const KegelSessionScreen({super.key});

  @override
  State<KegelSessionScreen> createState() => _KegelSessionScreenState();
}

class _KegelSessionScreenState extends State<KegelSessionScreen>
    with SingleTickerProviderStateMixin {
  static const _vibratingPhases = [
    KegelPhase.contract,
    KegelPhase.hold,
    KegelPhase.relax,
  ];

  late final KegelSessionEngine _engine;
  late final VibrationDriver _vibration;
  Timer? _completionTimer;

  @override
  void initState() {
    super.initState();
    _engine = KegelSessionEngine(vsync: this, patterns: kKegelTraining);
    _vibration = VibrationDriver(
      fillGetter: () => _engine.fill,
      isActive: () =>
          !_engine.isPaused && _vibratingPhases.contains(_engine.phase),
    );
    _vibration.init();
    _engine.addListener(_onEngineChanged);
    _engine.start();
  }

  void _onEngineChanged() {
    if (_engine.isComplete && _completionTimer == null) {
      _vibration.stop();
      _completionTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    _vibration.dispose();
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(flex: 3, child: Center(child: _buildCircle())),
            Expanded(child: _buildLabels()),
            _buildQueue(),
            _buildControls(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _vibration.enabled
                    ? Icons.vibration
                    : Icons.phonelink_erase_outlined,
                color: _vibration.enabled
                    ? AppColour.colorCustom
                    : AppColour.inactiveColor,
              ),
              tooltip: "Toggle vibration",
              onPressed: () {
                setState(() => _vibration.enabled = !_vibration.enabled);
                if (!_vibration.enabled) _vibration.stop();
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  Widget _buildCircle() => LayoutBuilder(
        builder: (context, constraints) {
          final diameter = constraints.biggest.shortestSide * 0.85;
          return AnimatedBuilder(
            animation: _engine.frameListenable,
            builder: (context, _) {
              if (_engine.isComplete) {
                return Icon(Icons.check_circle_outline,
                    size: diameter * 0.5, color: AppColour.colorCustom);
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  KegelCircle(fill: _engine.fill, diameter: diameter),
                  Text(
                    "${_engine.countdownSeconds}",
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      color: AppColour.colorCustom,
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

  Widget _buildLabels() => AnimatedBuilder(
        animation: _engine,
        builder: (context, _) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _engine.phaseLabel,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),
            Text(
              _engine.hintLabel,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );

  /// Shows the previous, current and next stage in three fixed slots that
  /// shift as the active stage advances.
  Widget _buildQueue() => AnimatedBuilder(
        animation: _engine,
        builder: (context, _) {
          final current = _currentChipIndex();
          return SizedBox(
            height: 40,
            child: Row(
              children: [
                _buildQueueSlot(current - 1, isCurrent: false),
                _buildQueueSlot(current, isCurrent: true),
                _buildQueueSlot(current + 1, isCurrent: false),
              ],
            ),
          );
        },
      );

  Widget _buildQueueSlot(int chip, {required bool isCurrent}) => Expanded(
        child: Text(
          _chipLabel(chip),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            color: isCurrent ? AppColour.colorCustom : Colors.grey[400],
          ),
        ),
      );

  /// The flattened stage sequence: exercise, Rest, exercise, Rest, ...
  /// Even chip => exercise; odd chip => Rest. Out-of-range chips are blank
  /// so the ends render an empty slot.
  String _chipLabel(int chip) {
    if (chip < 0 || chip >= kKegelTraining.length * 2 - 1) return "";
    return chip.isEven ? kKegelTraining[chip ~/ 2].name : "Rest";
  }

  int _currentChipIndex() => _engine.currentStageIndex;

  Widget _buildControls() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: AnimatedBuilder(
          animation: _engine,
          builder: (context, _) {
            if (_engine.isComplete) {
              return ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Text("Done"),
                ),
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.skip_previous),
                  color: AppColour.colorCustom,
                  onPressed: () {
                    _vibration.stop();
                    _engine.skipToPreviousStage();
                  },
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 64,
                  height: 64,
                  child: FloatingActionButton(
                    heroTag: "kegelPlayPause",
                    onPressed: () {
                      if (_engine.isPaused) {
                        _engine.resume();
                      } else {
                        _vibration.stop();
                        _engine.pause();
                      }
                    },
                    child: Icon(
                        _engine.isPaused ? Icons.play_arrow : Icons.pause,
                        size: 32),
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.skip_next),
                  color: AppColour.colorCustom,
                  onPressed: () {
                    _vibration.stop();
                    _engine.skipToNextStage();
                  },
                ),
              ],
            );
          },
        ),
      );
}

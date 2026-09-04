import 'package:flutter/material.dart';
import 'package:todo/tools/kegels/kegel_pattern.dart';
import 'package:todo/tools/kegels/kegel_session_screen.dart';
import 'package:todo/tools/kegels/waveform_icon.dart';

class KegelTrainingScreen extends StatelessWidget {
  static const String routeName = '/tools/kegels';

  const KegelTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kegels"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: kKegelTraining.length,
              itemBuilder: (context, index) =>
                  _buildPatternTile(context, kKegelTraining[index]),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(KegelSessionScreen.routeName),
                  child: const Text("Start Training"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternTile(BuildContext context, KegelPattern pattern) =>
      ListTile(
        leading: WaveformIcon(pattern: pattern),
        title: Text(pattern.name),
        subtitle: Text(_formatDuration(pattern.totalDuration)),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showInfo(context, pattern),
        ),
      );

  void _showInfo(BuildContext context, KegelPattern pattern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pattern.name),
        content: Text("${pattern.description}\n\n"
            "Contract ${_seconds(pattern.contractSeconds)}"
            "${pattern.holdSeconds > 0 ? " · Hold ${_seconds(pattern.holdSeconds)}" : ""}"
            " · Relax ${_seconds(pattern.relaxSeconds)}"
            "${pattern.waitSeconds > 0 ? " · Pause ${_seconds(pattern.waitSeconds)}" : ""}"
            " × ${pattern.reps} reps"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  static String _seconds(double seconds) =>
      "${seconds == seconds.roundToDouble() ? seconds.round() : seconds}s";

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final parts = <String>[
      if (minutes > 0) "$minutes minute${minutes == 1 ? "" : "s"}",
      if (seconds > 0 || minutes == 0) "$seconds second${seconds == 1 ? "" : "s"}",
    ];
    return parts.join(", ");
  }
}

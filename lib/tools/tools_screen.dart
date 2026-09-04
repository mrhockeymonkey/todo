import 'package:flutter/material.dart';
import 'package:todo/tools/kegels/kegel_training_screen.dart';

class ToolsScreen extends StatelessWidget {
  static const String routeName = '/tools';

  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tools"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildKegelsTile(context),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKegelsTile(BuildContext context) => ListTile(
      leading: const Icon(Icons.fitness_center),
      title: const Text("Kegels"),
      onTap: () =>
          Navigator.of(context).pushNamed(KegelTrainingScreen.routeName));
}

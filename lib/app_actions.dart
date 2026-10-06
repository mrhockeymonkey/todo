import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/providers/task_provider.dart';

import './screens/routines_screen.dart';
import './screens/settings_screen.dart';
import './tools/kegels/kegel_training_screen.dart';

enum AppActions {
  routines,
  settings,
  kegels,
  clearCompleted,
}

class AppAction {
  final String friendlyName;
  final IconData iconData;
  AppAction({
    required this.friendlyName,
    required this.iconData,
  });
}

class AppActionsHelper {
  static AppAction _getAction(AppActions action) {
    switch (action) {
      case AppActions.routines:
        return AppAction(
            friendlyName: "Routines", iconData: Entypo.circular_graph);
      case AppActions.settings:
        return AppAction(friendlyName: "Settings", iconData: Icons.settings);
      case AppActions.kegels:
        return AppAction(
            friendlyName: "Kegels", iconData: Icons.fitness_center);
      case AppActions.clearCompleted:
        return AppAction(
            friendlyName: "Clear Completed", iconData: Icons.delete);
    }
  }

  static void handleAction(AppActions value, BuildContext context) async {
    switch (value) {
      case AppActions.clearCompleted:
        await Provider.of<TaskProvider>(context, listen: false)
            .clearCompletedTasks();
        break;
      case AppActions.routines:
        Navigator.of(context).pushNamed(RoutinesScreen.routeName);
        break;
      case AppActions.settings:
        Navigator.of(context).pushNamed(SettingsScreen.routeName);
        break;
      case AppActions.kegels:
        Navigator.of(context).pushNamed(KegelTrainingScreen.routeName);
        break;
    }
  }

  static PopupMenuItem<AppActions> buildAction(AppActions actionChoice) {
    var action = _getAction(actionChoice);
    return PopupMenuItem<AppActions>(
      value: actionChoice,
      child: ListTile(
        title: Text(action.friendlyName),
        leading: Icon(action.iconData),
      ),
    );
  }
}

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/providers/task_provider.dart';

import './screens/settings_screen.dart';

enum AppActions {
  Settings,
  ClearCompleted,
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
      case AppActions.Settings:
        return AppAction(friendlyName: "Settings", iconData: Icons.settings);
      case AppActions.ClearCompleted:
        return AppAction(
            friendlyName: "Clear Completed", iconData: Icons.delete);
      default:
        throw "Unknown action!";
    }
  }

  static void handleAction(AppActions value, BuildContext context) async {
    switch (value) {
      case AppActions.ClearCompleted:
        await Provider.of<TaskProvider>(context, listen: false)
            .clearCompletedTasks();
        break;
      case AppActions.Settings:
        Navigator.of(context).pushNamed(SettingsScreen.routeName);
        break;
      default:
        throw "Unknown action!";
    }
  }

  static PopupMenuItem buildAction(AppActions actionChoice) {
    var action = _getAction(actionChoice);
    return PopupMenuItem(
      value: action,
      child: ListTile(
        title: Text(action.friendlyName),
        leading: Icon(action.iconData),
      ),
    );
  }
}

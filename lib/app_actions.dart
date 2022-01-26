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
    @required this.friendlyName,
    @required this.iconData,
  });
}

class AppActionsHelper {
  static Map<AppActions, AppAction> actions = {
    AppActions.ClearCompleted:
        new AppAction(friendlyName: "Clear Completed", iconData: Icons.delete),
    AppActions.Settings:
        new AppAction(friendlyName: "Settings", iconData: Icons.settings),
  };

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
        log("unknown");
    }
  }

  static Widget buildAction(AppActions action) => PopupMenuItem(
        value: action,
        child: ListTile(
          title: Text(actions[action].friendlyName),
          leading: Icon(actions[action].iconData),
        ),
      );
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';

import '../models/routine.dart';
import '../models/task.dart';
import '../providers/routine_provider.dart';
import '../providers/task_provider.dart';

class ExportJsonPage extends StatefulWidget {
  static const String routeName = '/export-json';

  @override
  State<StatefulWidget> createState() {
    return _ExportJsonPageState();
  }
}

class _ExportJsonPageState extends State<ExportJsonPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Backup Data"),
        // elevation: 0.0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    var json = _buildJson();

    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            ElevatedButton(
              child: Text(
                "Copy To Clipboard",
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(primary: Colors.green),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: json));
                print("copied to clipboard");
              },
            ),
            Container(
              child: Text(json),
              padding: EdgeInsets.symmetric(horizontal: 10.0),
            ),
          ],
        ))
      ],
    );
  }

  String _buildJson() {
    List<Map<String, dynamic>> exportedTasks = [];
    List<Map<String, dynamic>> exportedRoutines = [];

    final backlogTaskProvider = Provider.of<TaskProvider>(context);
    final routineProvider = Provider.of<RoutineProvider>(context);

    backlogTaskProvider.items
        .where((t) => !t.isDone)
        .forEach((t) => exportedTasks.add(_createTaskExport(t)));

    routineProvider.items
        .forEach((r) => exportedRoutines.add(_createRoutineExport(r)));

    Map<String, dynamic> appData = {
      "version": 1,
      "tasks": exportedTasks,
      "routines": exportedRoutines,
    };

    return jsonEncode(appData);
  }

  Map<String, dynamic> _createTaskExport(Task task) => {
        "id": task.id,
        "title": task.title,
        "dueDateMsSinceEpoch": task.dueDate?.millisecondsSinceEpoch ?? 0,
        "notes": task.notes
      };

  Map<String, dynamic> _createRoutineExport(Routine routine) => {
        "id": routine.id,
        "title": routine.title,
        "recurNum": routine.recurNum,
        "recurLen": routine.recurLen,
        "notes": routine.notes,
      };
}

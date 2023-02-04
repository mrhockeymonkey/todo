// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:convert';

import 'package:todo/models/repeat_schedule.dart';

import '../../date.dart';
import '../routine.dart';
import '../task.dart';

// darts json capabilities are a bit lacking and involve code generation for strong typing
// this is easier and recommended for small projects but fault prone...
class ExportDataV1 {
  final int version = 1;
  final List<Task> tasks;
  final List<Routine> routines;

  static const String _versionProp = "version";
  static const String _tasksProp = "tasks";
  static const String _routinesProp = "routines";

  ExportDataV1(
    this.tasks,
    this.routines,
  );

  factory ExportDataV1.fromJson(String json) {
    var inputData = jsonDecode(json);
    List<dynamic> importTasksData = inputData[_tasksProp];
    List<dynamic> importRoutinesData = inputData[_routinesProp];

    var tasks = importTasksData
        .map((t) => Task(
              title: t["title"],
              notes: t["notes"],
              dueDate: t["dueDateMsSinceEpoch"] == null
                  ? null
                  : Date.fromMillisecondsSinceEpoch(t["dueDateMsSinceEpoch"]),
            ))
        .toList();

    var routines = importRoutinesData
        .map((r) => Routine(
              title: r["title"],
              schedule: RepeatSchedule(), // TODO update
              notes: r["notes"],
              lastCompletedDate: r["lastCompletedDateMsSinceEpoch"] == null
                  ? null
                  : Date.fromMillisecondsSinceEpoch(
                      r["lastCompletedDateMsSinceEpoch"]),
            ))
        .toList();

    return ExportDataV1(tasks, routines);
  }

  String toJson() {
    Map<String, dynamic> exportData = {};
    exportData[_versionProp] = version;
    List<Map<String, dynamic>> exportedTasks = [];
    List<Map<String, dynamic>> exportedRoutines = [];

    tasks.forEach((t) => exportedTasks.add(_createTaskExport(t)));
    routines.forEach((r) => exportedRoutines.add(_createRoutineExport(r)));

    exportData[_tasksProp] = exportedTasks;
    exportData[_routinesProp] = exportedRoutines;

    return jsonEncode(exportData);
  }

  Map<String, dynamic> _createTaskExport(Task task) => {
        "id": task.id,
        "title": task.title,
        "dueDateMsSinceEpoch": task.dueDate?.millisecondsSinceEpoch,
        "notes": task.notes
      };

  Map<String, dynamic> _createRoutineExport(Routine routine) => {
        "id": routine.id,
        "title": routine.title,
        "recurNum": 0, // TODO update export/import
        "recurLen": 0,
        "notes": routine.notes,
        "lastCompletedDateMsSinceEpoch":
            routine.lastCompletedDate.millisecondsSinceEpoch,
      };
}

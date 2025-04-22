// ignore_for_file: avoid_function_literals_in_foreach_calls

import '../routine.dart';
import '../task.dart';
import '../category.dart';

// darts json capabilities are a bit lacking and involve code generation for strong typing
// this is easier and recommended for small projects but fault prone...
class ExportContainer {
  final int version = 1;
  final List<Task> tasks;
  final List<Routine> routines;
  final List<Category> categories;

  static const String _versionProp = "version";
  static const String _tasksProp = "tasks";
  static const String _routinesProp = "routines";
  static const String _categoriesProp = "categories";

  ExportContainer(
    this.tasks,
    this.routines,
    this.categories,
  );

  ExportContainer.fromJson(Map<String, dynamic> json)
      : tasks = ((json[_tasksProp] ?? []) as List<dynamic>)
            .map((e) => Task.fromJson(e))
            .toList(),
        routines = ((json[_routinesProp] ?? []) as List<dynamic>)
            .map((e) => Routine.fromJson(e))
            .toList(),
        categories = ((json[_categoriesProp] ?? []) as List<dynamic>)
            .map((e) => Category.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() => {
        _versionProp: version,
        _tasksProp: tasks,
        _routinesProp: routines,
        _categoriesProp: categories,
      };
}

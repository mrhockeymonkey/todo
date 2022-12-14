import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

import 'package:todo/models/daily_plan_todo.dart';
import 'package:todo/models/day_plan_backlog_task.dart';
import 'package:todo/models/day_plan_base.dart';
import 'package:todo/models/day_plan_routine.dart';
import 'package:todo/models/routine.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models/throw_away_task.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/providers/throw_away_task_provider.dart';
import 'package:todo/date.dart';

class DayPlanList extends StatefulWidget {
  final Date date;

  const DayPlanList({
    super.key,
    required this.date,
  });

  @override
  State<StatefulWidget> createState() => DayPlanListState();
}

class DayPlanListState extends State<DayPlanList> {
  bool _includeOutstanding = false;
  List<DayPlanToDo> _dayPlanToDos = [];
  List<DayPlanBacklogTask> _dayPlanTasks = [];
  List<DayPlanRoutine> _dayPlanRoutines = [];
  List<DayPlanBase> _dayPlanItems = [];

  @override
  void didChangeDependencies() {
    debugPrint("DidChangeDependencies: ${_toStringCustom()}");
    super.didChangeDependencies();

    if (widget.date == Date.now()) {
      _includeOutstanding = true;
    }

    final throwAwayTaskProvider = Provider.of<ThrowAwayTaskProvider>(context);
    final backlogTaskProvider = Provider.of<TaskProvider>(context);
    final routineProvider = Provider.of<RoutineProvider>(context);

    _dayPlanToDos = throwAwayTaskProvider
        .getByDate(widget.date)
        .map((e) => DayPlanToDo(todo: e))
        .toList();

    _dayPlanTasks = backlogTaskProvider
        .getByDate(widget.date, includeOutstanding: _includeOutstanding)
        .map((e) => DayPlanBacklogTask(task: e))
        .toList();

    _dayPlanRoutines = routineProvider.items
        .where((r) =>
            r.dueDate.isAtSameMomentAs(widget.date) ||
            (_includeOutstanding && r.dueDate.isBefore(widget.date)))
        .map((e) => DayPlanRoutine(routine: e))
        .toList();

    _dayPlanItems = [];

    for (var element in _dayPlanToDos) {
      _dayPlanItems.add(element);
    }
    for (var element in _dayPlanTasks) {
      _dayPlanItems.add(element);
    }
    for (var element in _dayPlanRoutines) {
      _dayPlanItems.add(element);
    }

    _dayPlanItems.sort((a, b) => a.order.compareTo(b.order)); // descending
    _dayPlanItems.sort((a, b) => a.isDone ? 1 : -1); // completed last
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Build: ${_toStringCustom()}");

    return ReorderableSliverList(
      delegate: ReorderableSliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var item = _dayPlanItems[index];
          return item.build(context);
        },
        childCount: _dayPlanItems.length,
      ),
      onReorder: _onReorder,
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    debugPrint("moved $oldIndex --> $newIndex");

    var moved = _dayPlanItems.removeAt(oldIndex);
    _dayPlanItems.insert(newIndex, moved);

    var next = 0;
    List<ThrowAwayTask> updatedToDos = [];
    List<Task> updatedTasks = [];
    List<Routine> updatedRoutines = [];

    for (var item in _dayPlanItems) {
      debugPrint("${item.toString()} is now $next");

      switch (item.runtimeType) {
        case DayPlanToDo:
          ThrowAwayTask todo = (item as DayPlanToDo).item;
          updatedToDos.add(todo.copyWith(order: next));
          break;
        case DayPlanBacklogTask:
          Task task = (item as DayPlanBacklogTask).item;
          updatedTasks.add(task.copyWith(order: next));
          break;
        case DayPlanRoutine:
          Routine routine = (item as DayPlanRoutine).item;
          updatedRoutines.add(routine.copyWith(order: next));
          break;
        default:
          throw ("Unknown type for day plan list!");
      }

      next++;
    }

    Provider.of<ThrowAwayTaskProvider>(context, listen: false)
        .updateAll(updatedToDos);
    Provider.of<TaskProvider>(context, listen: false).updateAll(updatedTasks);
    Provider.of<RoutineProvider>(context, listen: false)
        .updateAll(updatedRoutines);
  }

  String _toStringCustom() =>
      "$runtimeType (${widget.date.toString()}) ${_includeOutstanding ? "(Today)" : ""}";
}

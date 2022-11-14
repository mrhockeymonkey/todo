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

  DayPlanList({
    required this.date,
  });

  @override
  State<StatefulWidget> createState() => new DayPlanListState();
}

class DayPlanListState extends State<DayPlanList> {
  bool _includeOutstanding = false;
  List<DayPlanToDo> _dayPlanToDos = [];
  List<DayPlanBacklogTask> _dayPlanTasks = [];
  List<DayPlanRoutine> _dayPlanRoutines = [];
  List<DayPlanBase> _dayPlanItems = [];

  @override
  void didChangeDependencies() {
    print("DidChangeDependencies: ${this._toStringCustom()}");
    super.didChangeDependencies();

    if (widget.date == Date.now()) {
      _includeOutstanding = true;
    }

    final throwAwayTaskProvider = Provider.of<ThrowAwayTaskProvider>(context);
    final backlogTaskProvider = Provider.of<TaskProvider>(context);
    final routineProvider = Provider.of<RoutineProvider>(context);

    _dayPlanToDos = throwAwayTaskProvider
        .getByDate(widget.date)
        .map((e) => new DayPlanToDo(todo: e))
        .toList();

    _dayPlanTasks = backlogTaskProvider
        .getByDate(widget.date, includeOutstanding: _includeOutstanding)
        .map((e) => new DayPlanBacklogTask(task: e))
        .toList();

    _dayPlanRoutines = routineProvider.items
        .where((r) =>
            r.dueDate.isAtSameMomentAs(widget.date) ||
            (_includeOutstanding && r.dueDate.isBefore(widget.date)))
        .map((e) => new DayPlanRoutine(routine: e))
        .toList();

    _dayPlanItems = []; // TODO covariance??

    _dayPlanToDos.forEach((element) {
      _dayPlanItems.add(element);
    });
    _dayPlanTasks.forEach((element) {
      _dayPlanItems.add(element);
    });
    _dayPlanRoutines.forEach((element) {
      _dayPlanItems.add(element);
    });

    _dayPlanItems.sort((a, b) => a.order.compareTo(b.order)); // descending
  }

  @override
  Widget build(BuildContext context) {
    print("Build: ${_toStringCustom()}");

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
    print("moved $oldIndex --> $newIndex");

    var moved = _dayPlanItems.removeAt(oldIndex);
    _dayPlanItems.insert(newIndex, moved);

    var next = 0;
    List<ThrowAwayTask> updatedToDos = [];
    List<Task> updatedTasks = [];
    List<Routine> updatedRoutines = [];

    _dayPlanItems.forEach((item) {
      print("${item.toString()} is now $next");

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
    });

    Provider.of<ThrowAwayTaskProvider>(context, listen: false)
        .updateAll(updatedToDos);
    Provider.of<TaskProvider>(context, listen: false).updateAll(updatedTasks);
    Provider.of<RoutineProvider>(context, listen: false)
        .updateAll(updatedRoutines);
  }

  String _toStringCustom() =>
      "${this.runtimeType} (${widget.date.toString()}) ${_includeOutstanding ? "(Today)" : ""}";
}
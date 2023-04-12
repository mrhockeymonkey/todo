import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

import 'package:todo/models/daily_plan_todo.dart';
import 'package:todo/models/day_plan_task_ptr.dart';
import 'package:todo/models/day_plan_base.dart';
import 'package:todo/models/day_plan_routine_ptr.dart';
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
  List<DayPlanBase> _dayPlanItems = [];

  @override
  void didChangeDependencies() {
    debugPrint("DidChangeDependencies: ${_toStringCustom()}");
    super.didChangeDependencies();

    if (widget.date == Date.now()) {
      _includeOutstanding = true;
    }

    final throwAwayTaskProvider = Provider.of<ThrowAwayTaskProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final routineProvider = Provider.of<RoutineProvider>(context);

    var items = throwAwayTaskProvider.getByDate(widget.date);
    _dayPlanItems = items.map<DayPlanBase>((e) {
      if (e.taskId != null) {
        return DayPlanTaskPtr(
          todo: e,
          task: taskProvider.getItemById(
              e.taskId!), // TODO move this into the DayPlanTaskPtr class?
        );
      } else if (e.routineId != null) {
        return DayPlanRoutinePtr(
          todo: e,
          routine: routineProvider.getItemById(e.routineId!),
        );
      } else {
        return DayPlanToDo(todo: e);
      }
    }).toList();

    _dayPlanItems.sort((a, b) => a.order.compareTo(b.order)); // descending
    _dayPlanItems.sort((a, b) => b.isFlagged ? 1 : 0); // flagged first
    _dayPlanItems.sort((a, b) => a.isDone ? 1 : 0); // completed last
  }

  @override
  Widget build(BuildContext context) {
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

    for (var item in _dayPlanItems) {
      debugPrint("${item.toString()} is now $next");

      updatedToDos.add(item.item.copyWith(order: next));

      next++;
    }

    Provider.of<ThrowAwayTaskProvider>(context, listen: false)
        .updateAll(updatedToDos);
  }

  String _toStringCustom() =>
      "$runtimeType (${widget.date.toString()}) ${_includeOutstanding ? "(Today)" : ""}";
}

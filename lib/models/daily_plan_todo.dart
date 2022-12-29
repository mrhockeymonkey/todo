import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/models/day_plan_base.dart';
import 'package:todo/models/throw_away_task.dart';
import 'package:todo/widgets/flagged_icon.dart';
import 'package:uuid/uuid.dart';

import '../providers/throw_away_task_provider.dart';
import 'day_plan_actions.dart';

class DayPlanToDo extends DayPlanBase<ThrowAwayTask> {
  ThrowAwayTask todo;

  DayPlanToDo({required this.todo});

  @override
  Widget build(BuildContext context) => Dismissible(
        key: Key(const Uuid().v1()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) => _handleDismiss(context, direction),
        child: ListTile(
          leading: todo.done
              ? Icon(Icons.check, color: Colors.grey[350])
              : FlaggedIcon(
                  icon: Entypo.minus,
                  showFlag: todo.isFlagged,
                  color: AppColour.colorCustom,
                ),
          // const Icon(
          //     Entypo.minus,
          //     color: AppColour.colorCustom,
          //   ),
          trailing: DayPlanActions(
            handleSnooze: _handleSnooze,
            handleFlag: _handleFlag,
          ),
          title: TextFormField(
            textCapitalization: TextCapitalization.words,
            initialValue: todo.title.isEmpty ? null : item.title,
            enabled: !todo.done,
            autofocus: todo.title == "",
            onEditingComplete: () async =>
                await Provider.of<ThrowAwayTaskProvider>(context, listen: false)
                    .saveStashed(),
            onChanged: (String newValue) =>
                Provider.of<ThrowAwayTaskProvider>(context, listen: false)
                    .stash(todo.copyWith(title: newValue)),
            style: todo.done
                ? const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  )
                : null,
            cursorColor: Colors.black,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Do Something",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );

  void _handleDismiss(
    BuildContext context,
    DismissDirection direction,
  ) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false)
          .addOrUpdate(todo.donee());

  void _handleSnooze(BuildContext context) {
    var oneDay = const Duration(days: 1);
    var snoozedTodo = todo.copyWith(date: todo.date.addFromNow(oneDay));

    Provider.of<ThrowAwayTaskProvider>(context, listen: false)
        .addOrUpdate(snoozedTodo);
  }

  void _handleFlag(BuildContext context) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false)
          .addOrUpdate(todo.copyWith(isFlagged: !todo.isFlagged));

  @override
  int get order => todo.order;

  @override
  String toString() => "$runtimeType: ${todo.title}";

  @override
  Type get itemtype => runtimeType;

  @override
  ThrowAwayTask get item => todo;

  @override
  bool get isDone => todo.done;

  @override
  bool get isFlagged => todo.isFlagged;
}

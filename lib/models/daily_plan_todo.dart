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

class DayPlanToDo extends DayPlanBase {
  final ThrowAwayTask todo;

  DayPlanToDo({required this.todo});

  @override
  Widget build(BuildContext context) => Dismissible(
        key: Key(const Uuid().v1()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) => _handleDismiss(context, direction),
        child: ListTile(
          leading: todo.isDone
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
            handleRemove: _handleRemove,
          ),
          title: TextFormField(
            textCapitalization: TextCapitalization.words,
            initialValue: todo.title.isEmpty ? null : todo.title,
            enabled: !todo.isDone,
            autofocus: todo.title == "",
            onEditingComplete: () async =>
                await Provider.of<ThrowAwayTaskProvider>(context, listen: false)
                    .saveStashed(),
            onChanged: (String newValue) =>
                Provider.of<ThrowAwayTaskProvider>(context, listen: false)
                    .stash(todo.copyWith(title: newValue)),
            style: todo.isDone
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
          .addOrUpdate(todo.done());

  void _handleSnooze(BuildContext context) {
    var oneDay = const Duration(days: 1);
    var snoozedTodo =
        todo.copyWith(date: todo.date.add(oneDay));

    Provider.of<ThrowAwayTaskProvider>(context, listen: false)
        .addOrUpdate(snoozedTodo);
  }

  void _handleFlag(BuildContext context) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false)
          .addOrUpdate(todo.copyWith(isFlagged: !todo.isFlagged));

  void _handleRemove(BuildContext context) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false)
          .delete(todo.id!);

  @override
  bool get isDone => todo.isDone;

  @override
  bool get isFlagged => todo.isFlagged;

  @override
  int get order => todo.order;
}

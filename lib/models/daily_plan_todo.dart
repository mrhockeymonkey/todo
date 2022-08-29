import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/models/day_plan_base.dart';
import 'package:todo/models/throw_away_task.dart';
import 'package:uuid/uuid.dart';

import '../providers/throw_away_task_provider.dart';

class DayPlanToDo extends DayPlanBase<ThrowAwayTask> {
  ThrowAwayTask todo;

  DayPlanToDo({@required this.todo});

  @override
  Widget build(BuildContext context) => Dismissible(
        key: Key(Uuid().v1()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) => _handleDismiss(context, direction, item),
        child: ListTile(
          leading: todo.done
              ? Icon(Icons.check, color: Colors.grey[350])
              : Icon(
                  Entypo.minus,
                  color: AppColour.colorCustom,
                ),
          trailing: Icon(Icons.drag_indicator_sharp),
          title: TextFormField(
            textCapitalization: TextCapitalization.words,
            initialValue: todo.title.isEmpty ? null : item.title,
            enabled: !todo.done,
            //autofocus: _shouldFocusTitleField,
            onEditingComplete: () async =>
                await Provider.of<ThrowAwayTaskProvider>(context, listen: false)
                    .saveStashed(),
            onChanged: (String newValue) =>
                Provider.of<ThrowAwayTaskProvider>(context, listen: false)
                    .stash(todo.copyWith(title: newValue)),
            style: todo.done
                ? TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  )
                : null,
            cursorColor: Colors.black,
            decoration: InputDecoration(
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
    ThrowAwayTask task,
  ) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false).addOrUpdate(
          new ThrowAwayTask(
              id: task.id, title: task.title, done: true, date: task.date));

  @override
  int get order => todo.order;

  @override
  String toString() => "${this.runtimeType}: ${todo.title}";

  @override
  Type get itemtype => this.runtimeType;

  @override
  ThrowAwayTask get item => todo;
}

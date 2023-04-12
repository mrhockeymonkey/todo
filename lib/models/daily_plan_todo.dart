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
  DayPlanToDo({required ThrowAwayTask todo}) : super(item: todo);

  @override
  Widget build(BuildContext context) => Dismissible(
        key: Key(const Uuid().v1()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) => _handleDismiss(context, direction),
        child: ListTile(
          leading: super.item.isDone
              ? Icon(Icons.check, color: Colors.grey[350])
              : FlaggedIcon(
                  icon: Entypo.minus,
                  showFlag: super.item.isFlagged,
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
            initialValue: super.item.title.isEmpty ? null : item.title,
            enabled: !super.item.isDone,
            autofocus: super.item.title == "",
            onEditingComplete: () async =>
                await Provider.of<ThrowAwayTaskProvider>(context, listen: false)
                    .saveStashed(),
            onChanged: (String newValue) =>
                Provider.of<ThrowAwayTaskProvider>(context, listen: false)
                    .stash(super.item.copyWith(title: newValue)),
            style: super.item.isDone
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
          .addOrUpdate(super.item.done());

  void _handleSnooze(BuildContext context) {
    var oneDay = const Duration(days: 1);
    var snoozedTodo =
        super.item.copyWith(date: super.item.date.addFromNow(oneDay));

    Provider.of<ThrowAwayTaskProvider>(context, listen: false)
        .addOrUpdate(snoozedTodo);
  }

  void _handleFlag(BuildContext context) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false)
          .addOrUpdate(super.item.copyWith(isFlagged: !super.item.isFlagged));
}

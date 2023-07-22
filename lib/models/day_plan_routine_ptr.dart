import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/models/day_plan_base.dart';
import 'package:todo/models/routine.dart';
import 'package:todo/models/throw_away_task.dart';
import 'package:uuid/uuid.dart';

import '../providers/routine_provider.dart';
import '../providers/throw_away_task_provider.dart';
import '../screens/routine_detail_screen.dart';
import '../widgets/flagged_icon.dart';
import '../widgets/routine_icon.dart';
import 'day_plan_actions.dart';

class DayPlanRoutinePtr extends DayPlanBase {
  final Routine routine;

  DayPlanRoutinePtr({
    required ThrowAwayTask todo,
    required this.routine,
  }) : super(item: todo);

  @override
  Widget build(BuildContext context) => Dismissible(
        key: Key(const Uuid().v1()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) => _handleDismiss(context, direction),
        child: ListTile(
          leading: !routine.isDue
              ? Icon(Icons.check, color: Colors.grey[350])
              : RoutineIcon(
                  color: AppColour.colorCustom,
                  isFlagged: routine.isFlagged,
                ),
          title: Text(
            routine.title,
            style: !routine.isDue
                ? const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  )
                : null,
          ),
          trailing: DayPlanActions(
            // handleSnooze: _handleSnooze,
            // handleFlag: _handleFlag,
            handleRemove: _handleRemove,
          ),
          isThreeLine: false,
          onTap: () => Navigator.of(context).pushNamed(
            RoutineDetailScreen.routeName,
            arguments: routine.id,
          ),
        ),
      );

  void _handleDismiss(
    BuildContext context,
    DismissDirection direction,
  ) {
    Provider.of<ThrowAwayTaskProvider>(context, listen: false)
        .addOrUpdate(super.item.done());
    Provider.of<RoutineProvider>(context, listen: false)
        .addOrUpdate(routine.done());
  }

  // void _handleSnooze(BuildContext context) {
  //   var oneDay = const Duration(days: 1);
  //   var snoozedRoutine =
  //       routine.copyWith(nextDueDateTime: routine.dueDate.addFromNow(oneDay));

  //   Provider.of<RoutineProvider>(context, listen: false)
  //       .addOrUpdate(snoozedRoutine);
  // }

  // void _handleFlag(BuildContext context) =>
  //     Provider.of<RoutineProvider>(context, listen: false)
  //         .addOrUpdate(routine.copyWith(isFlagged: !routine.isFlagged));

  void _handleRemove(BuildContext context) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false)
          .delete(super.item.id!);
}

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/models/day_plan_base.dart';
import 'package:todo/models/routine.dart';
import 'package:uuid/uuid.dart';

import '../providers/routine_provider.dart';
import '../screens/routine_detail_screen.dart';
import '../widgets/flagged_icon.dart';
import '../widgets/routine_icon.dart';
import 'day_plan_actions.dart';

class DayPlanRoutine extends DayPlanBase<Routine> {
  final Routine routine;

  DayPlanRoutine({required this.routine});

  @override
  Widget build(BuildContext context) => Dismissible(
        key: Key(const Uuid().v1()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) => _handleDismiss(context, direction),
        child: ListTile(
          leading: RoutineIcon(
            color: AppColour.colorCustom,
            isFlagged: routine.isFlagged,
          ),
          // leading: const RoutineIcon(color: AppColour.colorCustom),
          title: Text(routine.title),
          trailing: DayPlanActions(
            handleSnooze: _handleSnooze,
            handleFlag: _handleFlag,
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
    Provider.of<RoutineProvider>(context, listen: false)
        .addOrUpdate(routine.done());
  }

  void _handleSnooze(BuildContext context) {
    var oneDay = const Duration(days: 1);
    var snoozedRoutine =
        routine.copyWith(nextDueDateTime: routine.dueDate.addFromNow(oneDay));

    Provider.of<RoutineProvider>(context, listen: false)
        .addOrUpdate(snoozedRoutine);
  }

  void _handleFlag(BuildContext context) =>
      Provider.of<RoutineProvider>(context, listen: false)
          .addOrUpdate(routine.copyWith(isFlagged: !routine.isFlagged));

  @override
  int get order => routine.order;

  @override
  String toString() => "$runtimeType: ${routine.title}";

  @override
  Type get itemtype => runtimeType;

  @override
  Routine get item => routine;

  @override
  bool get isDone => false;

  @override
  bool get isFlagged => routine.isFlagged;
}

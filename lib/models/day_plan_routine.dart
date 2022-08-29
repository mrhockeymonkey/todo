import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/app_colour.dart';
import 'package:todo/app_constants.dart';
import 'package:todo/models/day_plan_base.dart';
import 'package:todo/models/routine.dart';
import 'package:uuid/uuid.dart';

import '../providers/routine_provider.dart';
import '../screens/routine_detail_screen.dart';
import '../widgets/routine_icon.dart';

class DayPlanRoutine extends DayPlanBase<Routine> {
  final Routine routine;

  DayPlanRoutine({required this.routine});

  @override
  Widget build(BuildContext context) => Dismissible(
        key: Key(Uuid().v1()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) => _handleDismiss(context, direction, routine),
        child: ListTile(
          leading: RoutineIcon(color: AppColour.colorCustom),
          title: Text(routine.title),
          trailing: Icon(AppConstants.DragIndicator),
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
    Routine routine,
  ) {
    Provider.of<RoutineProvider>(context, listen: false)
        .addOrUpdate(routine.copyAsDone());
  }

  @override
  int get order => routine.order;

  @override
  String toString() => "${this.runtimeType}: ${routine.title}";

  @override
  Type get itemtype => this.runtimeType;

  @override
  Routine get item => routine;
}

import 'package:flutter/material.dart';

import 'package:todo/gauge/animated_gauge.dart';
import 'package:todo/screens/routine_detail_screen.dart';
import 'package:todo/models/routine.dart';

class RoutineItem extends StatelessWidget {
  final Routine routine;

  RoutineItem({
    @required this.routine,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        height: 40,
        width: 40,
        child: AnimatedGauge(
          percent: routine.percent,
        ),
      ),
      title: Text(routine.title),
      subtitle: Text("${routine.dueWhen} _${routine.dueDate}"),
      trailing: Text(routine.order.toString()),
      onTap: () => Navigator.of(context).pushNamed(
        RoutineDetailScreen.routeName,
        arguments: routine.id,
      ),
    );
  }
}

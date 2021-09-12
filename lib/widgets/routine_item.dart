import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import 'package:todo/gauge/animated_gauge.dart';
import 'package:todo/providers/routine_provider.dart';
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
        height: 70,
        width: 70,
        child: AnimatedGauge(
          percent: routine.percent,
        ),
      ),
      title: Text(routine.title),
      subtitle: Text(routine.dueWhen),
      onTap: () => Navigator.of(context).pushNamed(
        RoutineDetailScreen.routeName,
        arguments: routine.id,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';

import 'package:todo/gauge/animated_gauge.dart';
import 'package:todo/screens/routine_detail_screen.dart';
import 'package:todo/models/routine.dart';
import 'package:todo/widgets/add_to_dayplan_icon.dart';

import '../date.dart';
import '../providers/throw_away_task_provider.dart';

class RoutineItem extends StatelessWidget {
  final Routine routine;

  const RoutineItem({
    super.key,
    required this.routine,
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
      subtitle: Text(routine.dueWhen),
      trailing: _buildPopupMenu(context),
      onTap: () => Navigator.of(context).pushNamed(
        RoutineDetailScreen.routeName,
        arguments: routine.id,
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) => PopupMenuButton<void>(
        onSelected: (_) => {},
        itemBuilder: (context) => <PopupMenuEntry<void>>[
          PopupMenuItem<void>(
            child: ListTile(
              title: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleAddToPlan(context);
                      },
                      icon: const AddToDayPlanIcon())
                ],
              ),
            ),
          ),
        ],
      );

  void _handleAddToPlan(BuildContext context) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false)
          .addFromRoutine(routine, Date.now());
}

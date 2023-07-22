import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/widgets/add_to_dayplan_icon.dart';

import '../providers/throw_away_task_provider.dart';
import '../widgets/remove_from_dayplan_icon.dart';

class DayPlanActions extends StatelessWidget {
  final Function? handleSnooze;
  final Function? handleFlag;
  final Function? handleRemove;

  const DayPlanActions({
    super.key,
    this.handleFlag,
    this.handleSnooze,
    this.handleRemove,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<void>(
        onSelected: (_) => {},
        itemBuilder: (context) => <PopupMenuEntry<void>>[
          PopupMenuItem<void>(
            child: ListTile(
              title: Row(
                children: [
                  handleFlag == null
                      ? Container()
                      : IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            handleFlag!(context);
                          },
                          icon: const Icon(Entypo.flag)),
                  handleSnooze == null
                      ? Container()
                      : IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            handleSnooze!(context);
                          },
                          icon: const Icon(Icons.snooze)),
                  handleRemove == null
                      ? Container()
                      : IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            handleRemove!(context);
                          },
                          icon: const RemoveFromDayPlanIcon()),
                ],
              ),
            ),
          ),
        ],
      );

  static void doNothing() {}
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/routine.dart';

import 'package:todo/providers/routine_provider.dart';
import 'package:todo/widgets/routine_item.dart';
import 'package:uuid/uuid.dart';

class RoutineList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new RoutineListState();
}

class RoutineListState extends State<RoutineList> {
  @override
  void initState() {
    //Provider.of<RoutineProvider>(context, listen: false).fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Build: RoutineList");
    final routineProvider = Provider.of<RoutineProvider>(context);
    final routines = routineProvider.items;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          Routine routine = routines[index];
          return Dismissible(
            key: Key(Uuid().v1()), // dissmissed widget will reappear
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) => _handleDismiss(direction, routine),
            child: RoutineItem(routine: routine),
          );
        },
        childCount: routines.length,
      ),
    );
  }

  void _handleDismiss(DismissDirection direction, Routine routine) {
    Provider.of<RoutineProvider>(context, listen: false)
        .addOrUpdate(routine.done());
  }
}

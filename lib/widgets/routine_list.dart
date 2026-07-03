import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:todo/models/routine.dart';

import 'package:todo/providers/routine_provider.dart';
import 'package:todo/widgets/routine_item.dart';
import 'package:uuid/uuid.dart';

class RoutineList extends StatefulWidget {
  const RoutineList({super.key});

  @override
  State<StatefulWidget> createState() => RoutineListState();
}

class RoutineListState extends State<RoutineList> {
  
  List<Routine> _routines = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routineProvider = Provider.of<RoutineProvider>(context);
    _routines = routineProvider.items;
  }


  @override
  Widget build(BuildContext context) {
    return ReorderableSliverList(
      delegate: ReorderableSliverChildBuilderDelegate(
        (BuildContext context, int index) {
          
          Routine routine = _routines[index];
          
          return Dismissible(
            key: Key(const Uuid().v1()), // dissmissed widget will reappear
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) => _handleDismiss(direction, routine),
            child: RoutineItem(routine: routine),
          );
        },
        childCount: _routines.length,
      ),
      onReorder: _onReorder,
      controller: _scrollController,
    );
  }

  void _handleDismiss(DismissDirection direction, Routine routine) {
    Provider.of<RoutineProvider>(context, listen: false)
        .addOrUpdate(routine.done());
  }

  void _onReorder(int oldIndex, int newIndex) {
    debugPrint("moved $oldIndex --> $newIndex");

    var moved = _routines.removeAt(oldIndex);
    _routines.insert(newIndex, moved);

    var next = 0;
    List<Routine> updatedRoutines = [];

    for (var item in _routines) {
      debugPrint("${item.toString()} is now $next");
      updatedRoutines.add(item.copyWith(order: next));

      next++;
    }

    Provider.of<RoutineProvider>(context, listen: false)
        .updateAll(updatedRoutines);
  }
}

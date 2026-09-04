import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/day_plan_routine_ptr.dart';
import 'package:todo/models/routine.dart';
import 'package:todo/providers/routine_provider.dart';

class RoutinePeek extends StatefulWidget {
  const RoutinePeek({super.key});

  @override
  State<StatefulWidget> createState() => RoutinePeekState();
}

class RoutinePeekState extends State<RoutinePeek> {
  DayPlanRoutinePtr? routineView;

  @override
  void initState() {
    super.initState();
    _setRoutine(Provider.of<RoutineProvider>(context, listen: false));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setRoutine(Provider.of<RoutineProvider>(context));
  }

  @override
  Widget build(BuildContext context) {
    return routineView != null ? routineView!.build(context) : Container();
    
    
    // if (routineView == null) {
    //   return Container();
    // }
    // return Column(
    //   children: [
    //     //TextHeader(text: ""), 
    //   routineView!.build(context),],
    // );
  }

  void _setRoutine(RoutineProvider provider) {
    Routine? routine = provider.items.where((r) => r.isDue).firstOrNull;

    if (routine != null) {
      routineView = DayPlanRoutinePtr(routine: routine);
    }
  }
}

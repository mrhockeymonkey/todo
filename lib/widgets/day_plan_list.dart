import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:todo/day_of_week_factory.dart';
import 'package:todo/models/category.dart';
import 'package:todo/models/pinnedDayOfWeek.dart';
import 'package:todo/models/pinnedRoutine.dart';
import 'package:todo/models/pinnedTask.dart';
import 'package:todo/models/pinnedItemBase.dart';
import 'package:todo/models/pinned_later.dart';
import 'package:todo/models/pinned_missed.dart';
import 'package:todo/models/routine.dart';
import 'package:todo/models/task.dart';
import 'package:todo/models/throw_away_task.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/datetime_extensions.dart';

import 'package:todo/providers/task_provider.dart';
import 'package:todo/providers/throw_away_task_provider.dart';
import 'package:todo/widgets/task_item.dart';
import 'package:uuid/uuid.dart';

import '../date.dart';
import '../models/day_plan.dart';
import '../providers/day_plan_provider.dart';

class DayPlanList extends StatefulWidget {
  final Date date;

  DayPlanList({
    @required this.date,
  });

  @override
  State<StatefulWidget> createState() => new DayPlanListState();
}

class DayPlanListState extends State<DayPlanList> {
  @override
  void initState() {
    super.initState();
    // Provider.of<TaskProvider>(context, listen: false).fetch();
    // Provider.of<RoutineProvider>(context, listen: false).fetch();
  }

  @override
  Widget build(BuildContext context) {
    final throwAwayTaskProvider = Provider.of<ThrowAwayTaskProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final routineProvider = Provider.of<RoutineProvider>(context);

    final List<ThrowAwayTask> throwAwayTasks =
        throwAwayTaskProvider.items; // TODO get by date

    // final List<ThrowAwayTask> throwAwayTasks = dayPlan

    return ReorderableSliverList(
      delegate: ReorderableSliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var item = throwAwayTasks[index];
          final GlobalKey<FormState> _form = GlobalKey<FormState>();

          return Dismissible(
            key: Key(Uuid().v1()),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) =>
                {}, //_handleDismiss(context, direction, routine),
            child: ListTile(
              title: Form(
                key: _form,
                child: TextFormField(
                  // style: TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.words,
                  initialValue: item.title,
                  //autofocus: _shouldFocusTitleField,
                  onSaved: (String value) {
                    print("object");
                    //_taskTitle = value;
                  },

                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),

                  // decoration: InputDecoration(
                  //   hintText: 'Do Something',
                  //   labelText: 'Title',
                  //   focusedBorder: UnderlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.white)),
                  // ),
                ),
              ),
              // onTap: ,
            ),
          );
        },
        childCount: throwAwayTasks.length,
      ),
      onReorder: (oldIndex, newIndex) {
        // find date from old index
        print("$oldIndex -> $newIndex");

        // NEED TO SAVE TO DB
        // setState(() {
        //   if (pinnedItems[oldIndex].runtimeType == PinnedDayOfWeek) {
        //     print("dont move that");
        //     return;
        //   }
        //   PinnedItemBase row = pinnedItems.removeAt(oldIndex);
        //   pinnedItems.insert(newIndex, row);

        // reorder logic
        // loop through items
        // var currentDate = 0;
        // var currentOrder = 1;
        // pinnedItems.forEach((p) {
        //   print("checking $p...");

        //   // if (p.date > currentDate) {
        //   //   currentDate = p.date;
        //   //   currentOrder = 1;
        //   // }

        //   if (currentDate == 0) {
        //     currentDate = p.date;
        //   }

        //   currentDate = p.getNextDate(currentDate);
        //   p.date = currentDate;
        //   //currentDate = nextDate;

        //   currentOrder = p.getNextOrder(currentOrder);
        //   p.order = currentOrder;
        //currentOrder = nextOrder;

        // if (p.runtimeType == PinnedDayOfWeek ||
        //     p.runtimeType == PinnedLater) {
        //   print(
        //       "...${p.date}-${p.order} is a dayofweek so will not change");
        //   currentDate = p.date;
        //   currentOrder = 1;
        // } else {
        //   if (p.date != currentDate) {
        //     print("...setting date from ${p.date} -> $currentDate");
        //     p.date = currentDate;
        //   }

        //   if (p.order != currentOrder) {
        //     print("...setting order from ${p.order} -> $currentOrder");
        //     p.order = currentOrder;
        //   }
        //   currentOrder++;
        // }
        // });

        // pinnedItems.forEach((p) => p.updateTask());

        // List<Task> tasksToSave = pinnedItems
        //     .where((i) => i.itemType == PinnedTask.type)
        //     .map((p) => p.task)
        //     .toList(); // issaveable

        // Provider.of<TaskProvider>(context, listen: false)
        //     .updateAll(tasksToSave);
        //     });
      },
    );

    // return SliverReorderableList(
    //   itemBuilder: (context, index) => weekdays[index],
    //   itemCount: weekdays.length,
    //   onReorder: (oldIndex, newIndex) {
    //     print("r");
    //   },
    // );

    // return ReorderableListView(
    //   children: weekdays + taskItems,
    //   onReorder: (oldIndex, newIndex) {
    //     print("reorder");
    //   },
    // );

    // return SliverList(
    //   delegate: SliverChildBuilderDelegate(
    //     (BuildContext context, int index) {
    //       Task task = tasks[index];
    //       return Dismissible(
    //         key: Key(task.id),
    //         direction: DismissDirection.startToEnd,
    //         onDismissed: (direction) => _handleDismiss(direction, task),
    //         child: TaskItem(task: task),
    //       );
    //     },
    //     childCount: tasks.length,
    //   ),
    // );
  }

  // void _handleDismiss(DismissDirection direction, Task task) {
  //   task.done();
  //   Provider.of<TaskProvider>(context, listen: false).addOrUpdate(task);
  // }
}

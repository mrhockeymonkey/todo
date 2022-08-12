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
import 'package:todo/providers/category_provider.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/datetime_extensions.dart';

import 'package:todo/providers/task_provider.dart';
import 'package:todo/widgets/task_item.dart';

class PinnedList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new PinnedListState();
}

class PinnedListState extends State<PinnedList> {
  //List<PinnedItem> _pinnedItems;

  @override
  void initState() {
    Provider.of<TaskProvider>(context, listen: false).fetch();
    Provider.of<RoutineProvider>(context, listen: false).fetch();
    super.initState();

    // _pinnedItems = [
    //   new PinnedDayOfWeek(date: 20220109),
    //   //new PinnedTask(task: new Task(id: null, title: "Task 1"), date: 20220109, order: 1),
    //   //new PinnedTask(task: new Task(id: null, title: "Task 2"), date: 20220109, order: 2),
    //   new PinnedDayOfWeek(date: 20220110),
    //   //new PinnedTask( task: new Task(id: null, title: "Task 3"), date: 20220109, order: 1),
    // ];
  }

  @override
  Widget build(BuildContext context) {
    print("Build: PinnedList");
    final taskProvider = Provider.of<TaskProvider>(context);
    final routineProvider = Provider.of<RoutineProvider>(context);

    final DateTime lookAheadDate =
        PinnedDayOfWeekFactory.getPinnedDateTimeEnd();
    final List<PinnedItemBase> pinnedDaysOfWeek =
        PinnedDayOfWeekFactory.getPinnedDaysOfWeek();

    final List<PinnedItemBase> pinnedTasks = taskProvider.items
        .where((task) => task.isPinnedOrUpcoming(lookAheadDate))
        .map((t) => new PinnedTask(task: t))
        .toList();

    final List<PinnedItemBase> pinnedRoutines = routineProvider.items
        .where(
            (r) => r.displayOnPinned && r.nextDueDate.isBefore(lookAheadDate))
        .map((r) => new PinnedRoutine(r))
        .toList();

    final List<PinnedItemBase> pinnedItems =
        pinnedDaysOfWeek + pinnedTasks + pinnedRoutines;
    pinnedItems.sort((a, b) => a.listOrder.compareTo(b.listOrder));

    //pinnedItems.insert(0, new PinnedMissed());

    // new Dismissible(
    //   key: Key("1234"),
    //   direction: DismissDirection.startToEnd,
    //   onDismissed: (direction) => {},
    //   child: ListTile(
    //     key: ValueKey(20220128),
    //     title: Text("something"),
    //   ),
    // )

    //final taskItems = tasks.map((t) => new TaskItem(task: t)).toList();
    //final combined = weekdays + taskItems;

    return ReorderableSliverList(
      delegate: ReorderableSliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var item = pinnedItems[index];
          return item.build(context);
        },
        childCount: pinnedItems.length,
      ),
      onReorder: (oldIndex, newIndex) {
        // find date from old index
        print("$oldIndex -> $newIndex");

        // NEED TO SAVE TO DB
        setState(() {
          if (pinnedItems[oldIndex].runtimeType == PinnedDayOfWeek) {
            print("dont move that");
            return;
          }
          PinnedItemBase row = pinnedItems.removeAt(oldIndex);
          pinnedItems.insert(newIndex, row);

          // reorder logic
          // loop through items
          var currentDate = 0;
          var currentOrder = 1;
          pinnedItems.forEach((p) {
            print("checking $p...");

            // if (p.date > currentDate) {
            //   currentDate = p.date;
            //   currentOrder = 1;
            // }

            if (currentDate == 0) {
              currentDate = p.date;
            }

            currentDate = p.getNextDate(currentDate);
            p.date = currentDate;
            //currentDate = nextDate;

            currentOrder = p.getNextOrder(currentOrder);
            p.order = currentOrder;
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
          });

          pinnedItems.forEach((p) => p.updateTask());

          List<Task> tasksToSave = pinnedItems
              .where((i) => i.itemType == PinnedTask.type)
              .map((p) => p.task)
              .toList(); // issaveable

          Provider.of<TaskProvider>(context, listen: false)
              .updateAll(tasksToSave);
        });
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

  void _handleDismiss(DismissDirection direction, Task task) {
    task.done();
    Provider.of<TaskProvider>(context, listen: false).addOrUpdate(task);
  }
}

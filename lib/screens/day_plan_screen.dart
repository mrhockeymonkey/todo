import "package:flutter/material.dart";
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/throw_away_task.dart';
import 'package:todo/widgets/day_plan_list.dart';

import '../app_actions.dart';
import '../date.dart';
import '../providers/throw_away_task_provider.dart';
import '../widgets/text_header.dart';

class DailyScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Entypo.pin),
              Container(width: 10),
              Text("Day Plan"),
            ],
          ),
          actions: [
            PopupMenuButton<AppActions>(
              onSelected: (AppActions value) =>
                  AppActionsHelper.handleAction(value, context),
              itemBuilder: (context) => <PopupMenuEntry<AppActions>>[
                AppActionsHelper.buildAction(AppActions.Settings),
              ],
            )
          ],
        ),
        body: _buildBody(),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.ac_unit),
        // onPressed: () => Navigator.of(context).pushNamed(
        //     TaskDetailScreen.routeName,
        //     arguments: TaskDetailArgs(null, DateTime.now())),
        // ),
      );

  void _newThrowAwayTask(Date date) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false)
        ..saveStashed()
        ..addOrUpdate(new ThrowAwayTask(
            id: null, title: "", done: false, date: date, order: 99999));

  Widget _buildBody() {
    var today = DateTime.now();
    var tomorrow = DateTime.now().add(new Duration(days: 1));
    var dayAfterNext = DateTime.now().add(new Duration(days: 2));

    return CustomScrollView(
      controller: PrimaryScrollController.of(context) ?? ScrollController(),
      slivers: [
        // TODAY
        SliverToBoxAdapter(
            child: TextHeader(text: Jiffy(today).MMMMEEEEd.toString())),
        DayPlanList(date: Date(today)),
        SliverToBoxAdapter(
          child: Row(
            children: [
              IconButton(
                  onPressed: () => _newThrowAwayTask(Date(today)),
                  icon: Icon(Icons.add)),
            ],
          ),
        ),
        SliverFillRemaining(),

        //TOMORROW
        SliverToBoxAdapter(
            child: TextHeader(text: Jiffy(tomorrow).MMMMEEEEd.toString())),
        DayPlanList(
          date: Date(tomorrow),
        ),
        SliverToBoxAdapter(
          child: Row(
            children: [
              IconButton(
                  onPressed: () => _newThrowAwayTask(Date(tomorrow)),
                  icon: Icon(Icons.add)),
            ],
          ),
        ),

        // DAY AFTER
        SliverToBoxAdapter(
            child: TextHeader(text: Jiffy(dayAfterNext).MMMMEEEEd.toString())),
        DayPlanList(
          date: Date(dayAfterNext),
        ),
        SliverToBoxAdapter(
          child: Row(
            children: [
              IconButton(
                  onPressed: () => _newThrowAwayTask(Date(dayAfterNext)),
                  icon: Icon(Icons.add)),
            ],
          ),
        )
      ],
    );
  }
}

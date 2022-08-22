import "package:flutter/material.dart";
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/throw_away_task.dart';
import 'package:todo/widgets/day_plan_list.dart';

import '../date.dart';
import '../models/day_plan.dart';
import '../providers/throw_away_task_provider.dart';

class DailyScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  DayPlan dayPlan;

  @override
  void initState() {
    dayPlan = new DayPlan(date: DateTime.now());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Entypo.pin),
              Container(width: 10),
              Text("Daily ???"),
            ],
          ),
          // actions: [
          //   PopupMenuButton(
          //     onSelected: (value) =>
          //         AppActionsHelper.handleAction(value, context),
          //     itemBuilder: (context) => <PopupMenuEntry>[
          //       AppActionsHelper.buildAction(AppActions.Settings),
          //     ],
          //   )
          // ],
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.ac_unit),
          // onPressed: () => Navigator.of(context).pushNamed(
          //     TaskDetailScreen.routeName,
          //     arguments: TaskDetailArgs(null, DateTime.now())),
        ),
      );

  Widget _buildBody() => CustomScrollView(
        controller: PrimaryScrollController.of(context) ?? ScrollController(),
        slivers: [
          // SliverList(delegate: SliverChildListDelegate([DateHeader()])),
          SliverToBoxAdapter(
            child: Row(
              children: [Text("header")],
            ),
          ),
          DayPlanList(
              date: Date(
            DateTime.now().add(new Duration(days: 1)),
          )),
          SliverFillRemaining(),
          SliverToBoxAdapter(
            child: Row(
              children: [Text("header")],
            ),
          ),
          DayPlanList(
              date: Date(
            DateTime.now().add(new Duration(days: 2)),
          )),
          SliverToBoxAdapter(
            child: Row(
              children: [Text("header")],
            ),
          ),
          DayPlanList(
              date: Date(
            DateTime.now().add(new Duration(days: 3)),
          )),
          SliverToBoxAdapter(
            child: Row(
              children: [
                IconButton(
                    onPressed: () => Provider.of<ThrowAwayTaskProvider>(
                          context,
                          listen: false,
                        ).addOrUpdate(new ThrowAwayTask(
                            id: null, title: "newthing", done: false)),
                    icon: Icon(Icons.add)),
              ],
            ),
          )
        ],
      );
}

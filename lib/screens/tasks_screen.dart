import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:todo/app_actions.dart';
import 'package:todo/models/task_detail_args.dart';
import 'package:todo/screens/task_detail_screen.dart';
import 'package:todo/widgets/date_header.dart';
import 'package:todo/widgets/task_list.dart';

class TasksScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Entypo.list),
              Container(width: 10),
              Text("Tasks"),
            ],
          ),
          actions: [
            PopupMenuButton(
              onSelected: (value) =>
                  AppActionsHelper.handleAction(value, context),
              itemBuilder: (context) => <PopupMenuEntry>[
                AppActionsHelper.buildAction(AppActions.ClearCompleted),
                AppActionsHelper.buildAction(AppActions.Settings),
              ],
            )
          ],
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => Navigator.of(context).pushNamed(
              TaskDetailScreen.routeName,
              arguments: TaskDetailArgs(null, null)),
        ),
      );

  Widget _buildBody() => CustomScrollView(
        slivers: [
          SliverList(delegate: SliverChildListDelegate([DateHeader()])),
          TaskList(),
        ],
      );
}

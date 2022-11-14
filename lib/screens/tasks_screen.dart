import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:todo/screens/task_detail_screen.dart';
import 'package:todo/widgets/date_header.dart';
import 'package:todo/widgets/task_list.dart';

import '../app_actions.dart';

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
          actions: <Widget>[
            PopupMenuButton<AppActions>(
              onSelected: (AppActions value) =>
                  AppActionsHelper.handleAction(value, context),
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<AppActions>>[
                AppActionsHelper.buildAction(AppActions.ClearCompleted),
                AppActionsHelper.buildAction(AppActions.Settings),
              ],
            )
          ],
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => Navigator.of(context)
              .pushNamed(TaskDetailScreen.routeName, arguments: null),
        ),
      );

  Widget _buildBody() => CustomScrollView(
        slivers: [
          SliverList(delegate: SliverChildListDelegate([DateHeader()])),
          TaskList(),
        ],
      );
}

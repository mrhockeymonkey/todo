import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:todo/models/task_detail_args.dart';
import 'package:todo/screens/settings_screen.dart';
import 'package:todo/screens/task_detail_screen.dart';
import 'package:todo/widgets/date_header.dart';
import 'package:todo/widgets/pinned_list.dart';
import 'package:todo/widgets/task_list.dart';
import 'package:todo/app_actions.dart';

class PinnedScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PinnedScreenState();
}

class _PinnedScreenState extends State<PinnedScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Entypo.pin),
              Container(width: 10),
              Text("Pinned"),
            ],
          ),
          actions: [
            PopupMenuButton(
              onSelected: (value) =>
                  AppActionsHelper.handleAction(value, context),
              itemBuilder: (context) => <PopupMenuEntry>[
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
              arguments: TaskDetailArgs(null, DateTime.now())),
        ),
      );

  Widget _buildBody() => CustomScrollView(
        controller: PrimaryScrollController.of(context) ?? ScrollController(),
        slivers: [
          // SliverList(delegate: SliverChildListDelegate([DateHeader()])),
          PinnedList(),
        ],
      );
}

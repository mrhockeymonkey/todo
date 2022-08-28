import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:todo/widgets/date_header.dart';
import 'dart:math';

import 'package:todo/widgets/routine_list.dart';
import 'package:todo/screens/routine_detail_screen.dart';
import 'package:todo/app_actions.dart';

class RoutinesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Transform(
              transform: Matrix4.rotationY(pi),
              alignment: Alignment.center,
              child: Icon(Entypo.circular_graph),
            ),
            Container(width: 10),
            Text("Routines"),
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
                RoutineDetailScreen.routeName,
              )),
    );
  }

  Widget _buildBody() => CustomScrollView(
        slivers: [
          SliverList(delegate: SliverChildListDelegate([DateHeader()])),
          RoutineList(),
        ],
      );
}

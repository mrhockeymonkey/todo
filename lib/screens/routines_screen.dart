import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:todo/widgets/date_header.dart';
import 'dart:math';

import 'package:todo/widgets/routine_list.dart';
import 'package:todo/screens/routine_detail_screen.dart';
import 'package:todo/app_actions.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

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
              child: const Icon(Entypo.circular_graph),
            ),
            Container(width: 10),
            const Text("Routines"),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<AppActions>(
            onSelected: (AppActions value) =>
                AppActionsHelper.handleAction(value, context),
            itemBuilder: (context) => <PopupMenuEntry<AppActions>>[
              AppActionsHelper.buildAction(AppActions.settings),
            ],
          )
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.of(context).pushNamed(
                RoutineDetailScreen.routeName,
              )),
    );
  }

  Widget _buildBody() => CustomScrollView(
        slivers: [
          SliverList(delegate: SliverChildListDelegate([const DateHeader()])),
          const RoutineList(),
        ],
      );
}

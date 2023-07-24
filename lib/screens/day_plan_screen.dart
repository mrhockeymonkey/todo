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
  const DailyScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Entypo.list),
              Container(width: 10),
              const Text("Sennight"),
            ],
          ),
          actions: [
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
      );

  void _newThrowAwayTask(Date date) =>
      Provider.of<ThrowAwayTaskProvider>(context, listen: false)
        ..saveStashed()
        ..addOrUpdate(ThrowAwayTask(
          id: null,
          title: "",
          isDone: false,
          date: date,
          order: 99999,
        ));

  Widget _buildBody() {
    var numberDays = 7;
    var days = List<int>.generate(numberDays, (index) => index);

    var sections = <Widget>[];

    for (var day in days) {
      var date = DateTime.now().add(Duration(days: day));
      sections.add(SliverToBoxAdapter(
        child: TextHeader(text: Jiffy(date).MMMMEEEEd.toString()),
      ));
      sections.add(DayPlanList(date: Date(date)));
      sections.add(_buildAddButton(Date(date)));

      if (day == 0) {
        sections.add(const SliverFillRemaining());
      }
    }

    return CustomScrollView(
      controller: PrimaryScrollController.of(context) ?? ScrollController(),
      slivers: sections,
    );
  }

  Widget _buildAddButton(Date date) => SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              child: FloatingActionButton.small(
                child: const Icon(Icons.add),
                onPressed: () => _newThrowAwayTask(date),
                heroTag: date,
              ),
            )
          ],
        ),
        // Row(
        //   children: [
        //     IconButton(
        //         onPressed: () => _newThrowAwayTask(Date(today)),
        //         icon: const Icon(Icons.add)),
        //   ],
        // ),
      );
}

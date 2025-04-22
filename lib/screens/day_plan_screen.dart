import "package:flutter/material.dart";
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/throw_away_task.dart';
import 'package:todo/widgets/day_plan_list.dart';
import 'package:todo/widgets/routine_peek.dart';

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

  final GlobalKey targetKey = GlobalKey();
  final GlobalKey scrollViewKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // call back runs after widget has rendered
      _scrollToTarget();
    });
  }

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
    var days = List<int>.generate(numberDays, (index) => index - 1);
    var now = DateTime.now();
    var targetDay = now.hour < 3 ? -1 : 0;
    var sections = <Widget>[];

    for (var day in days) {
      var datetime = now.add(Duration(days: day));
      var date = Date(datetime);
      sections.add(SliverToBoxAdapter(
        child: TextHeader(
          key: day == targetDay ? targetKey : null,
          text: Jiffy.parseFromDateTime(datetime).MMMMEEEEd.toString(),),
      ));
      sections.add(DayPlanList(date: date));
      sections.add(_buildAddButton(date));

      if (day == targetDay) {
        sections.add(const SliverFillRemaining());
      }
    }

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            key: scrollViewKey,
            controller: _scrollController,
            slivers: sections,
          ),
        ),
        const RoutinePeek()
      ],
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
      );

  void _scrollToTarget() {
    final RenderBox renderBox = targetKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox scrollViewBox = scrollViewKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: scrollViewBox);
    final offset = position.dy + _scrollController.offset;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

}

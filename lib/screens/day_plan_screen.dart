import "package:flutter/material.dart";
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:todo/widgets/day_plan_list.dart';
import 'package:todo/widgets/new_day_plan_task.dart';
import 'package:todo/widgets/routine_peek.dart';

import '../app_actions.dart';
import '../date.dart';
import '../widgets/text_header.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen>
    with WidgetsBindingObserver {

  final GlobalKey targetKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  Date? _draftDate;
  Date _today = Date.now();
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // call back runs after widget has rendered
      _scrollToToday();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _wasBackgrounded = true;
      case AppLifecycleState.resumed:
        // Ignore brief inactive -> resumed blips (e.g. notification shade)
        if (_wasBackgrounded) {
          _wasBackgrounded = false;
          _refreshToday();
        }
      default:
        break;
    }
  }

  void _refreshToday() {
    final today = Date.now();
    if (today != _today) {
      setState(() => _today = today);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
    } else {
      _scrollToToday();
    }
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
                AppActionsHelper.buildAction(AppActions.routines),
                AppActionsHelper.buildAction(AppActions.settings),
                AppActionsHelper.buildAction(AppActions.kegels),
              ],
            )
          ],
        ),
        body: _buildBody(),
      );

  void _newTask(Date date) => setState(() => _draftDate = date);

  Widget _buildBody() {
    var numberDays = 7;
    var days = List<int>.generate(numberDays, (index) => index - 1);
    var sections = <Widget>[];

    for (var day in days) {
      var date = _today.addDays(day);
      var isToday = day == 0;
      sections.add(SliverToBoxAdapter(
        child: TextHeader(
          key: isToday ? targetKey : null,
          text: Jiffy.parseFromDateTime(date.dateTime).MMMMEEEEd.toString(),),
      ));

      if (isToday) {
        sections.add(const SliverToBoxAdapter(
          child: RoutinePeek(),
        ));
      }

      sections.add(DayPlanList(key: ValueKey(date), date: date));

      if (_draftDate == date) {
        sections.add(SliverToBoxAdapter(
          child: NewDayPlanTask(
            key: ValueKey(date),
            date: date,
            onClose: () => setState(() => _draftDate = null),
          ),
        ));
      }

      sections.add(_buildAddButton(date));

      if (isToday) {
        sections.add(const SliverFillRemaining());
      }
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: sections,
    );

    // return Column(
    //   children: [
    //     Expanded(
    //       child: CustomScrollView(
    //         key: scrollViewKey,
    //         controller: _scrollController,
    //         slivers: sections,
    //       ),
    //     ),
    //     const RoutinePeek()
    //   ],
    // );
  }

  Widget _buildAddButton(Date date) => SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              child: FloatingActionButton.small(
                onPressed: () => _newTask(date),
                heroTag: date,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.grey,
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                disabledElevation: 0,
                child: const Icon(Icons.add),
              ),
            )
          ],
        ),
      );

  void _scrollToToday() {
    final targetContext = targetKey.currentContext;
    if (!mounted || targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

}

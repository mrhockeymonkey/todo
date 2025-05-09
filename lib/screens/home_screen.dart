import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/providers/category_provider.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/providers/throw_away_task_provider.dart';
import 'package:todo/screens/day_plan_screen.dart';
import 'package:todo/screens/routines_screen.dart';
import 'package:todo/screens/tasks_screen.dart';
import 'package:todo/widgets/routine_icon.dart';
import 'package:todo/widgets/badge_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future? _dbFetch;
  int _selectedIndex = 1;
  int taskCount = 0;
  int routineCount = 0;
  final List<Widget> _pages = [
    const TasksScreen(),
    const DailyScreen(),
    const RoutinesScreen(),
  ];

  @override
  void didChangeDependencies() {
    _dbFetch ??= _dbFetch = Future.wait([
      Provider.of<CategoryProvider>(context).fetch(),
      Provider.of<TaskProvider>(context).fetch(),
      Provider.of<RoutineProvider>(context).fetch(),
      Provider.of<ThrowAwayTaskProvider>(context).fetch(),
    ]);

    super.didChangeDependencies();
  }

  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _dbFetch,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return Container();

          taskCount = Provider.of<TaskProvider>(context).isDueCount;
          routineCount = Provider.of<RoutineProvider>(context).isDueCount;

          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              body: _pages[_selectedIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _selectScreen,
                items: [
                  BottomNavigationBarItem(
                    label: '',
                    icon: BadgeIcon(
                        icon: const Icon(Entypo.pin), badgeCount: taskCount),
                  ),
                  const BottomNavigationBarItem(
                    label: '',
                    icon: Icon(Entypo.list),
                  ),
                  BottomNavigationBarItem(
                    label: '',
                    icon: BadgeIcon(
                        icon: const RoutineIcon(), badgeCount: routineCount),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

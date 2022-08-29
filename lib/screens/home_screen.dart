import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/providers/routine_provider.dart';
import 'package:todo/screens/day_plan_screen.dart';
import 'package:todo/screens/routines_screen.dart';
import 'package:todo/screens/tasks_screen.dart';
import 'package:todo/widgets/routine_icon.dart';
import 'package:todo/widgets/badge_icon.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  final List<Map<String, Object>> _pages = [
    {
      'page': TasksScreen(),
      'title': '',
    },
    {
      'page': DailyScreen(),
      'title': '',
    },
    {
      'page': RoutinesScreen(),
      'title': '',
    },
  ];

  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _pages[_selectedIndex]['page'],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _selectScreen,
          items: [
            BottomNavigationBarItem(
              label: '',
              icon: Icon(Entypo.pin),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: Icon(Entypo.list),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: BadgeIcon(
                icon: RoutineIcon(),
                badgeCount: Provider.of<RoutineProvider>(context).isDueCount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

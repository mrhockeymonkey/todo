import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'dart:math';
import 'package:provider/provider.dart';

import 'package:todo/providers/routine_provider.dart';
import 'package:todo/providers/task_provider.dart';
import 'package:todo/screens/daily_screen.dart';
import 'package:todo/screens/pinned_screen.dart';
import 'package:todo/screens/routines_screen.dart';
import 'package:todo/screens/tasks_screen.dart';
import '../widgets/badge_icon.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  final List<Map<String, Object>> _pages = [
    {
      'page': TasksScreen(),
      'title': 'Tasks',
    },
    {
      'page': PinnedScreen(),
      'title': 'Pinned',
    },
    {
      'page': DailyScreen(),
      'title': 'Daily',
    },
    {
      'page': RoutinesScreen(),
      'title': 'Habits',
    },
  ];

  @override
  void initState() {
    Provider.of<RoutineProvider>(context, listen: false).fetch();
    super.initState();
  }

  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _selectScreen,
        items: [
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Entypo.list, color: Colors.amber),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Entypo.pin, color: Colors.amber),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Entypo.air, color: Colors.amber),
          ),
          BottomNavigationBarItem(
              label: '',
              icon: BadgeIcon(
                icon: Transform(
                  transform: Matrix4.rotationY(pi),
                  alignment: Alignment.center,
                  child: Icon(Entypo.circular_graph, color: Colors.amber),
                ),
                badgeCount: Provider.of<RoutineProvider>(context).isDueCount,
              )),
        ],
      ),
    );
  }

  Widget _buildNotificationBlip(int count) => count <= 0
      ? SizedBox(
          height: 1,
          width: 1,
        )
      : new Positioned(
          right: 0,
          child: new Container(
            padding: EdgeInsets.all(1),
            decoration: new BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: BoxConstraints(
              minWidth: 12,
              minHeight: 12,
            ),
            child: new Text(
              count.toString(),
              style: new TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
}

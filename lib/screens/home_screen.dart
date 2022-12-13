import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:todo/providers/routine_provider.dart';
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
  int _selectedIndex = 1;
  final List<Widget> _pages = [
    const TasksScreen(),
    const DailyScreen(),
    const RoutinesScreen(),
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
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _selectScreen,
          items: const [
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
              icon: RoutineIcon(),
            ),
          ],
        ),
      ),
    );
  }
}

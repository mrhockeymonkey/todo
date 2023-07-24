import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:todo/screens/task_detail_screen.dart';
import 'package:todo/widgets/date_header.dart';
import 'package:provider/provider.dart';
import '../app_actions.dart';
import '../widgets/task_list.dart';
import '../widgets/text_header.dart';
import 'package:todo/providers/task_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<StatefulWidget> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Entypo.pin),
              Container(width: 10),
              const Text("Tasks"),
            ],
          ),
          actions: <Widget>[
            PopupMenuButton<AppActions>(
              onSelected: (AppActions value) =>
                  AppActionsHelper.handleAction(value, context),
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<AppActions>>[
                AppActionsHelper.buildAction(AppActions.clearCompleted),
                AppActionsHelper.buildAction(AppActions.settings),
              ],
            )
          ],
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.of(context)
              .pushNamed(TaskDetailScreen.routeName, arguments: null),
        ),
      );

  // Widget _buildBody() => CustomScrollView(
  //       slivers: [
  //         SliverList(delegate: SliverChildListDelegate([const DateHeader()])),
  //         const TaskList(),
  //       ],
  //     );

  Widget _buildBody() {
    var tasks = Provider.of<TaskProvider>(context).items;

    var completedTasks = tasks.where((t) => t.isDone).toList();
    var todoTasks = tasks.where((t) => !t.isDone);
    var dueTasks = todoTasks.where((t) => t.isDue).toList();
    var scheduledTasks =
        todoTasks.where((t) => !t.isDue && t.isScheduled).toList();
    var unscheduledTasks = todoTasks.where((t) => !t.isScheduled).toList();

    return CustomScrollView(
      slivers: [
        // DUE
        const SliverToBoxAdapter(child: TextHeader(text: "To Do...")),
        TaskList(tasks: dueTasks),
        const SliverFillRemaining(),

        //SCHEDULED
        const SliverToBoxAdapter(child: TextHeader(text: "Upcoming...")),
        TaskList(tasks: scheduledTasks),

        // AT SOME POINT
        const SliverToBoxAdapter(child: TextHeader(text: "Someday maybe...")),
        TaskList(tasks: unscheduledTasks),

        // COMPLETED
        const SliverToBoxAdapter(child: TextHeader(text: "Done...")),
        TaskList(tasks: completedTasks),
      ],
    );
  }
}

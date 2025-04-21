import 'package:todo/models/routine.dart';
import 'package:todo/providers/provider_base.dart';

import '../date.dart';
import '../models/task.dart';
import '../models/throw_away_task.dart';

class ThrowAwayTaskProvider extends ProviderBase<ThrowAwayTask> {
  final Map<String, ThrowAwayTask> _stash = {};

  ThrowAwayTaskProvider({
    required String tableName,
  }) : super(tableName: tableName) {
    clean();
  }

  @override
  ThrowAwayTask parse(Map<String, dynamic> json) =>
      ThrowAwayTask.fromJson(json);

  @override
  List<ThrowAwayTask> get items {
    var items = [...super.items];
    return items;
  }

  void clean() => items
      .where((i) => i.date.dateTime.isBefore(DateTime.now().add(const Duration(days: 2))))
      .where((i) => i.id != null)
      .forEach((i) => delete(i.id!));

  List<ThrowAwayTask> getByDate(Date date) =>
      items.where((i) => i.date.isAtSameMomentAs(date)).toList();

  void stash(ThrowAwayTask task) {
    if (task.id == null) return;

    _stash.update(
      task.id!,
      (_) => task,
      ifAbsent: () => task,
    );
  }

  Future saveStashed() async {
    await super.updateAll(_stash.values.toList());
    _stash.clear();
  }

  Future addFromTask(Task task, Date date) async =>
      await addOrUpdate(ThrowAwayTask(
          id: null,
          title: task.title,
          isDone: false,
          date: date,
          taskId: task.id));

  Future addFromRoutine(Routine routine, Date date) async =>
      await addOrUpdate(ThrowAwayTask(
          id: null,
          title: routine.title,
          isDone: false,
          date: date,
          routineId: routine.id));

  // @override
  // Future addOrUpdate(ThrowAwayTask item, {bool notify = true}) async {
  //   await super.updateAll(_stash.values.toList(), notify: false);
  //   _stash.clear();
  //   await super.addOrUpdate(item, notify: notify);
  // }
}

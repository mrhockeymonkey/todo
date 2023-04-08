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
      .where((i) => i.date.isBefore(Date.now()))
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

  Future AddFromTask(Task task, Date date) async => await addOrUpdate(
      ThrowAwayTask(id: null, title: task.title, done: false, date: date));

  // @override
  // Future addOrUpdate(ThrowAwayTask item, {bool notify = true}) async {
  //   await super.updateAll(_stash.values.toList(), notify: false);
  //   _stash.clear();
  //   await super.addOrUpdate(item, notify: notify);
  // }
}

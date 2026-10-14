import 'package:flutter_test/flutter_test.dart';
import 'package:todo/models/priority.dart';
import 'package:todo/models/task.dart';

void main() {
  test('new tasks default to not important', () {
    expect(const Task(title: 'a').priority, Priority.notImportant);
  });

  test('tasks saved before priority existed load as not important', () {
    final task = Task.fromJson({'id': '1', 'title': 'a'});
    expect(task.priority, Priority.notImportant);
  });

  test('unknown priority values load as not important', () {
    final task = Task.fromJson({'id': '1', 'title': 'a', 'priority': 'nope'});
    expect(task.priority, Priority.notImportant);
  });

  test('priority survives a json round trip', () {
    for (final priority in Priority.values) {
      final task = Task(id: '1', title: 'a', priority: priority);
      expect(Task.fromJson(task.toJson()).priority, priority);
    }
  });

  test('copyWith keeps priority unless overridden', () {
    const task = Task(title: 'a', priority: Priority.urgent);
    expect(task.copyWith(isDone: true).priority, Priority.urgent);
    expect(
      task.copyWith(priority: Priority.important).priority,
      Priority.important,
    );
  });
}

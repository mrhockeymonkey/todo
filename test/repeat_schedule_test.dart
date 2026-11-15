import 'package:flutter_test/flutter_test.dart';
import 'package:todo/date.dart';
import 'package:todo/models/repeat_schedule.dart';

void main() {
  RepeatSchedule on(List<int> d) =>
      RepeatSchedule(type: const ScheduleType.onDates(), dates: d);
  Date d(int y, int m, int day) => Date(DateTime(y, m, day));

  test('next chosen date later in the month', () {
    expect(on([5, 20]).calculateNextDueDate(d(2026, 11, 10)).day, 20);
  });
  test('wraps to next month', () {
    final n = on([5, 20]).calculateNextDueDate(d(2026, 11, 20));
    expect((n.month, n.day), (12, 5));
  });
  test('date 31 skips short months', () {
    final n = on([31]).calculateNextDueDate(d(2026, 11, 10));
    expect((n.month, n.day), (12, 31));
    final feb = on([31]).calculateNextDueDate(d(2027, 1, 31));
    expect((feb.month, feb.day), (3, 31));
  });
  test('works with an unsorted const list and no dates', () {
    expect(on([20, 5]).calculateNextDueDate(d(2026, 11, 10)).day, 20);
    expect(on(const []).calculateNextDueDate(d(2026, 11, 10)).day, 11);
  });
}

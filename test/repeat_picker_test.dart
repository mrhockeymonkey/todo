import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/models/repeat_schedule.dart';
import 'package:todo/widgets/repeat_picker.dart';

void main() {
  /// Opens the picker with [initial] and returns a getter for what it popped.
  Future<RepeatSchedule? Function()> open(
    WidgetTester tester,
    RepeatSchedule initial,
  ) async {
    RepeatSchedule? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (context) => TextButton(
                onPressed:
                    () async =>
                        result = await showDialog<RepeatSchedule>(
                          context: context,
                          builder: (_) => RepeatPicker(initial),
                        ),
                child: const Text('open'),
              ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return () => result;
  }

  Finder day(int d) => find.byKey(ValueKey('day-$d'));
  Finder ok() => find.widgetWithText(ElevatedButton, 'OK');

  testWidgets('picking days returns an on-dates schedule', (tester) async {
    final result = await open(tester, RepeatSchedule());

    await tester.tap(find.text('On dates'));
    await tester.pumpAndSettle();
    await tester.tap(day(20));
    await tester.tap(day(5));
    await tester.pump();
    await tester.tap(ok());
    await tester.pumpAndSettle();

    expect(result()!.type.value, const ScheduleType.onDates().value);
    expect(result()!.dates, [5, 20]);
  });

  testWidgets('OK is disabled until a day is chosen', (tester) async {
    await open(tester, RepeatSchedule());
    await tester.tap(find.text('On dates'));
    await tester.pumpAndSettle();

    expect(tester.widget<ElevatedButton>(ok()).onPressed, isNull);

    await tester.tap(day(3));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(ok()).onPressed, isNotNull);

    await tester.tap(day(3));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(ok()).onPressed, isNull);
  });

  testWidgets('an existing on-dates schedule opens on its days', (
    tester,
  ) async {
    final result = await open(
      tester,
      RepeatSchedule(type: const ScheduleType.onDates(), dates: [7, 14]),
    );

    expect(find.text('7th, 14th of every month'), findsOneWidget);
    await tester.tap(day(21));
    await tester.pump();
    await tester.tap(ok());
    await tester.pumpAndSettle();

    expect(result()!.dates, [7, 14, 21]);
  });

  testWidgets('switching back to periodic returns the periodic schedule', (
    tester,
  ) async {
    final result = await open(
      tester,
      RepeatSchedule(period: 3, periodType: const PeriodType.weeks()),
    );

    await tester.tap(find.text('On dates'));
    await tester.pumpAndSettle();
    await tester.tap(day(9));
    await tester.tap(find.text('Periodically'));
    await tester.pumpAndSettle();
    await tester.tap(ok());
    await tester.pumpAndSettle();

    expect(result()!.type.value, const ScheduleType.periodic().value);
    expect(result()!.period, 3);
    expect(result()!.periodType.value, 'weeks');
  });

  testWidgets('cancel returns nothing', (tester) async {
    final result = await open(tester, RepeatSchedule());

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result(), isNull);
  });
}

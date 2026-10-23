import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/models/priority.dart';
import 'package:todo/widgets/priority_menu.dart';

void main() {
  testWidgets('selecting a priority reports it', (tester) async {
    Priority? selected;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PriorityMenu(
          onSelected: (priority) => selected = priority,
          child: const Icon(Icons.circle),
        ),
      ),
    ));

    await tester.tap(find.byIcon(Icons.circle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Priority.urgent.label));
    await tester.pumpAndSettle();

    expect(selected, Priority.urgent);
  });
}

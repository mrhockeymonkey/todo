import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo/main.dart';

void main() {
  testWidgets('app starts and shows the home screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    // The home screen waits on the providers' storage fetch, which is real
    // IO, so let it complete outside the fake-async zone before pumping.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 500)));
    await tester.pump();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.route), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

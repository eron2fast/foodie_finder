import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foodie_finder/main.dart';  // Make sure this imports the correct entry point for your app

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build the widget tree (Make sure your app's entry point is correctly provided here)
    await tester.pumpWidget(const MyApp());  // MyApp() should be your app's root widget

    // Verify that the counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));  // Assuming you have an Icon button for incrementing
    await tester.pump();

    // Verify that the counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

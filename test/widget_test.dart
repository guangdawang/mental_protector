import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindark_app/app.dart';

void main() {
  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MindDarkApp(),
      ),
    );

    // Verify that app title is shown
    expect(find.text('心灵方舟'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('Settings button is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MindDarkApp(),
      ),
    );

    // Verify settings icon exists
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('History button is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MindDarkApp(),
      ),
    );

    // Verify history icon exists
    expect(find.byIcon(Icons.history), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:compass_go/main.dart';

void main() {
  testWidgets('COMPASS GO app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CompassGoApp()));
    
    // App can show either permission screen or main shell
    // Just verify the app initializes without error
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

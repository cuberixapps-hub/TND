// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:truth_or_dare/main.dart';

void main() {
  testWidgets('Truth or Dare app launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: TruthOrDareApp()));

    // Verify that the app title is displayed
    expect(find.text('Truth or Dare'), findsOneWidget);

    // Verify that the play button is displayed
    expect(find.text('PLAY NOW'), findsOneWidget);
  });
}

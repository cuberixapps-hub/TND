import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truth_or_dare/presentation/widgets/animated_card.dart';

void main() {
  group('AnimatedCard Widget Tests', () {
    testWidgets('should render with child content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedCard(child: Text('Test Content'))),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(AnimatedCard), findsOneWidget);
    });

    testWidgets('should apply custom background color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              backgroundColor: Colors.blue,
              child: Text('Colored Card'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedCard),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.decoration, isNotNull);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.blue);
    });

    testWidgets('should apply gradient when provided', (
      WidgetTester tester,
    ) async {
      const gradient = LinearGradient(colors: [Colors.red, Colors.blue]);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              gradient: gradient,
              child: Text('Gradient Card'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedCard),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, gradient);
    });

    testWidgets('should apply custom padding', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(20.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              padding: customPadding,
              child: Text('Padded Content'),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(AnimatedCard),
          matching: find.byType(Padding).last,
        ),
      );

      expect(padding.padding, customPadding);
    });

    testWidgets('should apply custom margin', (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(15.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              margin: customMargin,
              child: Text('Margin Card'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedCard),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.margin, customMargin);
    });

    testWidgets('should handle tap when onTap is provided', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              onTap: () => tapped = true,
              child: const Text('Tappable Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedCard));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('should not respond to tap when onTap is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedCard(child: Text('Non-tappable Card'))),
        ),
      );

      // Should not throw error when tapped without onTap
      await tester.tap(find.byType(AnimatedCard));
      await tester.pumpAndSettle();

      // Test passes if no error is thrown
      expect(find.byType(AnimatedCard), findsOneWidget);
    });

    testWidgets('should animate on tap down', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              onTap: () {},
              child: const Text('Animated Card'),
            ),
          ),
        ),
      );

      // Simulate tap down (press and hold)
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(AnimatedCard)),
      );

      // Pump multiple times to allow animation to progress
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));

      // Check that AnimatedBuilder exists (there may be multiple)
      expect(find.byType(AnimatedBuilder), findsWidgets);

      // Release the tap
      await gesture.up();
      await tester.pumpAndSettle();

      // Test passes if no error is thrown and animation completes
      expect(find.byType(AnimatedCard), findsOneWidget);
    });

    testWidgets('should apply custom border radius', (
      WidgetTester tester,
    ) async {
      final customRadius = BorderRadius.circular(30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              borderRadius: customRadius,
              child: const Text('Rounded Card'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedCard),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, customRadius);
    });

    testWidgets('should apply custom elevation', (WidgetTester tester) async {
      const customElevation = 20.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              elevation: customElevation,
              child: Text('Elevated Card'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedCard),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, true);

      // The blur radius should be related to elevation
      final shadow = decoration.boxShadow!.first;
      expect(shadow.blurRadius, greaterThan(0));
    });

    testWidgets('should apply custom shadow color', (
      WidgetTester tester,
    ) async {
      const customShadowColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              shadowColor: customShadowColor,
              child: Text('Red Shadow Card'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedCard),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);

      final shadow = decoration.boxShadow!.first;
      // Shadow color will have opacity applied
      expect(shadow.color.value, customShadowColor.withOpacity(0.1).value);
    });

    testWidgets('should clip content with border radius', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              borderRadius: BorderRadius.circular(20),
              child: Container(width: 200, height: 200, color: Colors.blue),
            ),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.circular(20));
    });

    testWidgets('should handle tap cancel', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCard(
              onTap: () {},
              child: const Text('Cancel Test Card'),
            ),
          ),
        ),
      );

      // Start a gesture
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(AnimatedCard)),
      );

      await tester.pump(const Duration(milliseconds: 50));

      // Cancel the gesture by moving far away
      await gesture.moveBy(const Offset(500, 500));
      await gesture.cancel();

      await tester.pumpAndSettle();

      // Card should return to normal state
      expect(find.byType(AnimatedCard), findsOneWidget);
    });

    testWidgets('should use default values when not specified', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedCard(child: Text('Default Card'))),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedCard),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;

      // Check default values
      expect(decoration.color ?? Colors.white, Colors.white);
      expect(decoration.borderRadius, BorderRadius.circular(20));
      expect(decoration.boxShadow, isNotNull);
    });
  });
}

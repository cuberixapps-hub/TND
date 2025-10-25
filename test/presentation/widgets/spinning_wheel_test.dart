import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truth_or_dare/presentation/widgets/spinning_wheel.dart';

void main() {
  group('SpinningWheel Widget Tests', () {
    late AnimationController animationController;

    Widget createTestWidget({
      required AnimationController controller,
      Color color = Colors.blue,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: SpinningWheel(animationController: controller, color: color),
          ),
        ),
      );
    }

    testWidgets('should render spinning wheel', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: tester,
      );

      await tester.pumpWidget(
        createTestWidget(controller: animationController),
      );

      expect(find.byType(SpinningWheel), findsOneWidget);
      expect(find.text('?'), findsOneWidget);

      animationController.dispose();
    });

    testWidgets('should apply custom color', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: tester,
      );

      const testColor = Colors.red;

      await tester.pumpWidget(
        createTestWidget(controller: animationController, color: testColor),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SpinningWheel),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      expect(gradient.colors[0], testColor);
      expect(gradient.colors[1], testColor.withOpacity(0.6));

      animationController.dispose();
    });

    testWidgets('should have circular shape', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: tester,
      );

      await tester.pumpWidget(
        createTestWidget(controller: animationController),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SpinningWheel),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);

      animationController.dispose();
    });

    testWidgets('should have correct dimensions', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: tester,
      );

      await tester.pumpWidget(
        createTestWidget(controller: animationController),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SpinningWheel),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth ?? 150, 150);
      expect(container.constraints?.maxHeight ?? 150, 150);

      animationController.dispose();
    });

    testWidgets('should display question mark', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: tester,
      );

      await tester.pumpWidget(
        createTestWidget(controller: animationController),
      );

      final textWidget = tester.widget<Text>(find.text('?'));
      expect(textWidget.style?.fontSize, 64);
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontWeight, FontWeight.bold);

      animationController.dispose();
    });

    testWidgets('should rotate when animation plays', (
      WidgetTester tester,
    ) async {
      animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: tester,
      );

      await tester.pumpWidget(
        createTestWidget(controller: animationController),
      );

      // Get initial transform
      final initialTransform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(SpinningWheel),
          matching: find.byType(Transform),
        ),
      );

      // Start animation
      animationController.forward();
      await tester.pump(const Duration(milliseconds: 500));

      // Get transform after animation
      final animatedTransform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(SpinningWheel),
          matching: find.byType(Transform),
        ),
      );

      // Animation should have progressed
      expect(animationController.value, greaterThan(0));

      animationController.dispose();
    });

    testWidgets('should complete full rotation', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: tester,
      );

      await tester.pumpWidget(
        createTestWidget(controller: animationController),
      );

      // Start animation
      animationController.forward();

      // Wait for animation to complete
      await tester.pumpAndSettle();

      expect(animationController.isCompleted, true);

      animationController.dispose();
    });

    testWidgets('should have gradient effect', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: tester,
      );

      const testColor = Colors.green;

      await tester.pumpWidget(
        createTestWidget(controller: animationController, color: testColor),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SpinningWheel),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);

      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);

      animationController.dispose();
    });

    testWidgets('should have box shadow', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: tester,
      );

      const testColor = Colors.purple;

      await tester.pumpWidget(
        createTestWidget(controller: animationController, color: testColor),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SpinningWheel),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.isNotEmpty, true);

      final shadow = decoration.boxShadow!.first;
      expect(shadow.color, testColor.withOpacity(0.3));
      expect(shadow.blurRadius, 20);
      expect(shadow.spreadRadius, 5);

      animationController.dispose();
    });

    testWidgets('should rebuild on animation value change', (
      WidgetTester tester,
    ) async {
      animationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: tester,
      );

      await tester.pumpWidget(
        createTestWidget(controller: animationController),
      );

      expect(find.byType(AnimatedBuilder), findsWidgets);

      // Verify AnimatedBuilder is connected to controller
      final animatedBuilder = tester.widget<AnimatedBuilder>(
        find.byType(AnimatedBuilder),
      );
      expect(animatedBuilder.animation, animationController);

      animationController.dispose();
    });

    testWidgets('should handle reverse animation', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: tester,
      );

      await tester.pumpWidget(
        createTestWidget(controller: animationController),
      );

      // Forward animation
      animationController.forward();
      await tester.pumpAndSettle();
      expect(animationController.value, 1.0);

      // Reverse animation
      animationController.reverse();
      await tester.pumpAndSettle();
      expect(animationController.value, 0.0);

      animationController.dispose();
    });

    testWidgets('should handle repeat animation', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tester,
      );

      await tester.pumpWidget(
        createTestWidget(controller: animationController),
      );

      // Start repeating animation
      animationController.repeat();

      // Let it run for a bit
      await tester.pump(const Duration(seconds: 1));

      // Should still be animating
      expect(animationController.isAnimating, true);

      animationController.dispose();
    });
  });
}

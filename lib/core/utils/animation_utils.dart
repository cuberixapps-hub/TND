import 'package:flutter/material.dart';

class AnimationUtils {
  // Refined duration constants for consistent timing
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 750);

  // Elegant curves for smooth motion
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve entranceCurve = Curves.easeOutQuart;
  static const Curve exitCurve = Curves.easeInQuart;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutSine;

  // Stagger delays for sequential animations
  static Duration staggerDelay(
    int index, {
    Duration baseDelay = const Duration(milliseconds: 50),
  }) {
    return baseDelay * index;
  }

  // Page transition builder
  static PageRouteBuilder createPageRoute({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOutCubic,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  // Hero-like scale transition
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    double beginScale = 0.8,
    double endScale = 1.0,
  }) {
    return ScaleTransition(
      scale: Tween(
        begin: beginScale,
        end: endScale,
      ).animate(CurvedAnimation(parent: animation, curve: entranceCurve)),
      child: child,
    );
  }
}

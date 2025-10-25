import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension AnimationExtensions on Widget {
  Widget slideDownIn({Duration? duration, Duration? delay}) {
    return animate()
        .fadeIn(duration: duration ?? 300.ms, delay: delay)
        .slideY(
          begin: -0.2,
          end: 0,
          duration: duration ?? 300.ms,
          delay: delay,
          curve: Curves.easeOutCubic,
        );
  }

  Widget slideUpIn({Duration? duration, Duration? delay}) {
    return animate()
        .fadeIn(duration: duration ?? 300.ms, delay: delay)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: duration ?? 300.ms,
          delay: delay,
          curve: Curves.easeOutCubic,
        );
  }
}

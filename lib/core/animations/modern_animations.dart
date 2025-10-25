import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/modern_design_system.dart';

/// Modern animation utilities for smooth, elegant transitions
class ModernAnimations {
  ModernAnimations._();

  // ============================================
  // ENTRANCE ANIMATIONS
  // ============================================
  
  /// Elegant fade and scale entrance
  static List<Effect> fadeScaleIn({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) {
    return [
      FadeEffect(
        delay: delay ?? Duration.zero,
        duration: duration ?? ModernDesignSystem.durationNormal,
        curve: curve ?? ModernDesignSystem.curveElegant,
      ),
      ScaleEffect(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        delay: delay ?? Duration.zero,
        duration: duration ?? ModernDesignSystem.durationNormal,
        curve: curve ?? ModernDesignSystem.curveSmooth,
      ),
    ];
  }

  /// Slide up with fade
  static List<Effect> slideUpIn({
    Duration? delay,
    Duration? duration,
    double beginY = 0.1,
  }) {
    return [
      FadeEffect(
        delay: delay ?? Duration.zero,
        duration: duration ?? ModernDesignSystem.durationSmooth,
        curve: ModernDesignSystem.curveElegant,
      ),
      SlideEffect(
        begin: Offset(0, beginY),
        end: Offset.zero,
        delay: delay ?? Duration.zero,
        duration: duration ?? ModernDesignSystem.durationSmooth,
        curve: ModernDesignSystem.curveSmooth,
      ),
    ];
  }

  /// Staggered list animation
  static List<Effect> staggeredListItem({
    required int index,
    Duration? baseDelay,
    Duration? duration,
  }) {
    final delay = (baseDelay ?? Duration.zero) + 
                  Duration(milliseconds: index * 60);
    
    return [
      FadeEffect(
        delay: delay,
        duration: duration ?? ModernDesignSystem.durationNormal,
        curve: ModernDesignSystem.curveElegant,
      ),
      SlideEffect(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
        delay: delay,
        duration: duration ?? ModernDesignSystem.durationNormal,
        curve: ModernDesignSystem.curveSmooth,
      ),
    ];
  }

  // ============================================
  // MICROINTERACTIONS
  // ============================================
  
  /// Subtle press animation
  static Widget pressAnimation({
    required Widget child,
    double scale = 0.98,
  }) {
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          duration: ModernDesignSystem.durationQuick,
          begin: const Offset(1, 1),
          end: Offset(scale, scale),
          curve: ModernDesignSystem.curveGentle,
        )
        .then()
        .scale(
          duration: ModernDesignSystem.durationQuick,
          begin: Offset(scale, scale),
          end: const Offset(1, 1),
          curve: ModernDesignSystem.curveGentle,
        );
  }

  /// Gentle pulse animation
  static List<Effect> gentlePulse({
    double scale = 1.05,
    Duration? duration,
  }) {
    return [
      ScaleEffect(
        begin: const Offset(1, 1),
        end: Offset(scale, scale),
        duration: duration ?? ModernDesignSystem.durationSlow,
        curve: ModernDesignSystem.curveGentle,
      ),
    ];
  }

  /// Shimmer effect for loading
  static List<Effect> shimmer({
    Duration? duration,
    Color? color,
  }) {
    return [
      ShimmerEffect(
        duration: duration ?? ModernDesignSystem.durationGentle,
        color: color ?? ModernDesignSystem.primaryLight.withOpacity(0.3),
        curve: ModernDesignSystem.curveElegant,
      ),
    ];
  }

  // ============================================
  // TRANSITION BUILDERS
  // ============================================
  
  /// Smooth page transition
  static Widget pageTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: ModernDesignSystem.curveElegant,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: ModernDesignSystem.curveSmooth,
        )),
        child: child,
      ),
    );
  }

  /// Modal slide up transition
  static Widget modalTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: ModernDesignSystem.curveSmooth,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0),
        ),
        child: child,
      ),
    );
  }

  // ============================================
  // CUSTOM ANIMATIONS
  // ============================================
  
  /// Ripple effect from center
  static Widget rippleAnimation({
    required Widget child,
    required AnimationController controller,
    Color? color,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (color ?? ModernDesignSystem.primaryColor)
                .withOpacity(0.3 * (1 - controller.value)),
          ),
          child: Transform.scale(
            scale: 1 + (controller.value * 2),
            child: child,
          ),
        );
      },
    );
  }

  /// Number counter animation
  static Widget countAnimation({
    required int value,
    required TextStyle style,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration ?? ModernDesignSystem.durationSlow,
      curve: ModernDesignSystem.curveSmooth,
      builder: (context, value, child) {
        return Text(
          value.toInt().toString(),
          style: style,
        );
      },
    );
  }

  /// Elegant loading indicator
  static Widget modernLoader({
    double size = 40,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? ModernDesignSystem.primaryColor,
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .rotate(duration: const Duration(seconds: 1))
          .fadeIn(duration: ModernDesignSystem.durationNormal),
    );
  }
}

/// Extension for easy animation application
extension AnimateExtension on Widget {
  Widget fadeScaleIn({Duration? delay, Duration? duration}) {
    return animate(effects: ModernAnimations.fadeScaleIn(
      delay: delay,
      duration: duration,
    ));
  }
  
  Widget slideUpIn({Duration? delay, Duration? duration}) {
    return animate(effects: ModernAnimations.slideUpIn(
      delay: delay,
      duration: duration,
    ));
  }
  
  Widget staggeredItem(int index, {Duration? baseDelay}) {
    return animate(effects: ModernAnimations.staggeredListItem(
      index: index,
      baseDelay: baseDelay,
    ));
  }
}





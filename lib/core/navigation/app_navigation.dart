import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../presentation/screens/home_screen.dart';
import '../theme/design_system.dart';

/// Navigation utilities and route management
class AppNavigation {
  // Prevent instantiation
  AppNavigation._();

  // ============================================
  // NAVIGATION METHODS
  // ============================================

  /// Navigate with slide transition from right
  static Future<T?> navigateSlideFromRight<T>(
    BuildContext context,
    Widget page, {
    Duration duration = DesignSystem.durationNormal,
  }) {
    HapticFeedback.lightImpact();
    return Navigator.push<T>(
      context,
      DesignSystem.slideTransition(
        page: page,
        duration: duration,
        beginOffset: const Offset(1.0, 0.0),
      ),
    );
  }

  /// Navigate with slide transition from bottom
  static Future<T?> navigateSlideFromBottom<T>(
    BuildContext context,
    Widget page, {
    Duration duration = DesignSystem.durationNormal,
  }) {
    HapticFeedback.lightImpact();
    return Navigator.push<T>(
      context,
      DesignSystem.slideTransition(
        page: page,
        duration: duration,
        beginOffset: const Offset(0.0, 1.0),
      ),
    );
  }

  /// Navigate with fade transition
  static Future<T?> navigateFade<T>(
    BuildContext context,
    Widget page, {
    Duration duration = DesignSystem.durationNormal,
  }) {
    HapticFeedback.lightImpact();
    return Navigator.push<T>(
      context,
      DesignSystem.fadeTransition(page: page, duration: duration),
    );
  }

  /// Replace current screen with slide transition
  static Future<T?> replaceWithSlide<T>(
    BuildContext context,
    Widget page, {
    Duration duration = DesignSystem.durationNormal,
    Offset beginOffset = const Offset(1.0, 0.0),
  }) {
    HapticFeedback.lightImpact();
    return Navigator.pushReplacement<T, T>(
      context,
      DesignSystem.slideTransition(
        page: page,
        duration: duration,
        beginOffset: beginOffset,
      ),
    );
  }

  /// Replace current screen with fade transition
  static Future<T?> replaceWithFade<T>(
    BuildContext context,
    Widget page, {
    Duration duration = DesignSystem.durationNormal,
  }) {
    HapticFeedback.lightImpact();
    return Navigator.pushReplacement<T, T>(
      context,
      DesignSystem.fadeTransition(page: page, duration: duration),
    );
  }

  /// Navigate to home and clear stack
  static Future<void> navigateToHome(BuildContext context) {
    HapticFeedback.mediumImpact();
    return Navigator.pushAndRemoveUntil(
      context,
      DesignSystem.fadeTransition(
        page: const HomeScreen(),
        duration: DesignSystem.durationSlow,
      ),
      (route) => false,
    );
  }

  /// Pop with haptic feedback
  static void pop<T>(BuildContext context, [T? result]) {
    HapticFeedback.lightImpact();
    Navigator.pop(context, result);
  }

  /// Pop until predicate with haptic feedback
  static void popUntil(BuildContext context, bool Function(Route) predicate) {
    HapticFeedback.lightImpact();
    Navigator.popUntil(context, predicate);
  }

  // ============================================
  // MODAL AND DIALOG METHODS
  // ============================================

  /// Show modal bottom sheet with consistent styling
  static Future<T?> showAppBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? DesignSystem.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignSystem.radius2xl),
        ),
      ),
      builder: (context) => child,
    );
  }

  /// Show dialog with consistent styling
  static Future<T?> showAppDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    HapticFeedback.lightImpact();
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusXl),
            ),
            child: child,
          ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showAppDialog<bool>(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: DesignSystem.headlineSmall.copyWith(
                color: DesignSystem.neutral900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.space4),
            Text(
              message,
              style: DesignSystem.bodyMedium.copyWith(
                color: DesignSystem.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.space6),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      cancelText,
                      style: DesignSystem.titleMedium.copyWith(
                        color: DesignSystem.neutral600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DesignSystem.space3),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor ?? DesignSystem.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          DesignSystem.radiusMd,
                        ),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: DesignSystem.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }
}

/// Route names for navigation
class AppRoutes {
  static const String home = '/';
  static const String playerSetup = '/player-setup';
  static const String gameplay = '/gameplay';
  static const String scoreboard = '/scoreboard';
  static const String gameOver = '/game-over';
  static const String settings = '/settings';
  static const String customChallenge = '/custom-challenge';
}

/// Navigation observer for tracking navigation events
class AppNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('Push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('Pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logNavigation('Replace', newRoute, oldRoute);
  }

  void _logNavigation(
    String action,
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  ) {
    debugPrint(
      '🧭 Navigation: $action - '
      'From: ${previousRoute?.settings.name ?? 'unknown'} '
      'To: ${route?.settings.name ?? 'unknown'}',
    );
  }
}

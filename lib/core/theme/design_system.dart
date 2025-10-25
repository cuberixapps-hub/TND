import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Comprehensive Design System for Truth or Dare App
/// This file contains all design tokens and utilities for consistent UI
class DesignSystem {
  // Prevent instantiation
  DesignSystem._();

  // ============================================
  // SPACING SYSTEM (4px base unit)
  // ============================================
  static const double space0 = 0;
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space7 = 28;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;

  // ============================================
  // CORNER RADIUS SYSTEM
  // ============================================
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2xl = 24;
  static const double radiusFull = 999;

  // ============================================
  // COLOR PALETTE
  // ============================================

  // Primary Colors
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryIndigo = Color(0xFF6366F1);

  // Game Mode Colors
  static const Color colorKids = Color(0xFF10B981);
  static const Color colorTeens = Color(0xFF3B82F6);
  static const Color colorAdult = Color(0xFFEF4444);
  static const Color colorCouples = Color(0xFFEC4899);

  // Semantic Colors
  static const Color colorSuccess = Color(0xFF10B981);
  static const Color colorWarning = Color(0xFFF59E0B);
  static const Color colorError = Color(0xFFEF4444);
  static const Color colorInfo = Color(0xFF3B82F6);

  // Neutral Colors
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFF8F9FA);
  static const Color backgroundSecondary = Colors.white;
  static const Color backgroundTertiary = Color(0xFFF3F4F6);

  // ============================================
  // TYPOGRAPHY SYSTEM
  // ============================================

  // Display (for hero sections)
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // Headlines
  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.4,
  );

  // Titles
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.5,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
  );

  // Body Text
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  // Labels & Captions
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // ============================================
  // ELEVATION SYSTEM (Shadows)
  // ============================================

  static List<BoxShadow> elevationNone = [];

  static List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevation5 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> elevationColored(Color color, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // ============================================
  // ANIMATION DURATIONS
  // ============================================

  static const Duration durationInstant = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationVerySlow = Duration(milliseconds: 600);

  // ============================================
  // ANIMATION CURVES
  // ============================================

  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveEaseOutCubic = Curves.easeOutCubic;
  static const Curve curveElasticOut = Curves.elasticOut;
  static const Curve curveBounceOut = Curves.bounceOut;

  // ============================================
  // ICON SIZES
  // ============================================

  static const double iconSizeXs = 16;
  static const double iconSizeSm = 20;
  static const double iconSizeMd = 24;
  static const double iconSizeLg = 28;
  static const double iconSizeXl = 32;

  // ============================================
  // BUTTON STYLES
  // ============================================

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: space6, vertical: space4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLg),
    ),
    elevation: 0,
    textStyle: titleMedium,
  );

  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: neutral200,
    foregroundColor: neutral700,
    padding: const EdgeInsets.symmetric(horizontal: space6, vertical: space4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLg),
    ),
    elevation: 0,
    textStyle: titleMedium,
  );

  // ============================================
  // COMMON WIDGETS
  // ============================================

  static Widget iconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    double size = iconSizeMd,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusMd),
        child: Container(
          padding: const EdgeInsets.all(space3),
          decoration: BoxDecoration(
            color: backgroundSecondary,
            borderRadius: BorderRadius.circular(radiusMd),
            boxShadow: elevation2,
          ),
          child: Icon(icon, color: color ?? neutral700, size: size),
        ),
      ),
    );
  }

  static Widget card({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    List<BoxShadow>? elevation,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(space4),
      decoration: BoxDecoration(
        color: backgroundColor ?? backgroundSecondary,
        borderRadius: BorderRadius.circular(borderRadius ?? radiusLg),
        boxShadow: elevation ?? elevation2,
      ),
      child: child,
    );
  }

  static Widget divider({double height = 1, Color? color, EdgeInsets? margin}) {
    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(vertical: space4),
      color: color ?? neutral200,
    );
  }

  // ============================================
  // RESPONSIVE UTILITIES
  // ============================================

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 375;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 375 &&
        MediaQuery.of(context).size.width < 768;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  static double responsiveValue(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    if (isSmallScreen(context)) return small;
    if (isMediumScreen(context)) return medium;
    return large;
  }

  // ============================================
  // PAGE TRANSITIONS
  // ============================================

  static PageRouteBuilder<T> slideTransition<T>({
    required Widget page,
    Duration duration = durationNormal,
    Offset beginOffset = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(
          begin: beginOffset,
          end: Offset.zero,
        ).chain(CurveTween(curve: curveEaseOutCubic));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: duration,
    );
  }

  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget page,
    Duration duration = durationNormal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: duration,
    );
  }
}





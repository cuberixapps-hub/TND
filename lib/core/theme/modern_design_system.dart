import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Design System for Truth or Dare App
/// Focused on elegance, simplicity, and exceptional user experience
class ModernDesignSystem {
  ModernDesignSystem._();

  // ============================================
  // MODERN COLOR PALETTE
  // ============================================

  // Primary Colors - Sophisticated and calming
  static const Color primaryColor = Color(0xFF5B4CF5); // Royal Purple
  static const Color primaryLight = Color(0xFF7B6FF7);
  static const Color primaryDark = Color(0xFF4338CA);

  // Secondary Colors - Accent and contrast
  static const Color secondaryColor = Color(0xFFFF6B6B); // Coral
  static const Color secondaryLight = Color(0xFFFF8787);
  static const Color secondaryDark = Color(0xFFE55555);

  // Game Mode Colors - Refined and harmonious
  static const Color colorKids = Color(0xFF4ECDC4); // Turquoise
  static const Color colorTeens = Color(0xFF5B4CF5); // Purple
  static const Color colorAdult = Color(0xFFFF6B6B); // Coral
  static const Color colorCouples = Color(0xFFFF4757); // Rose

  // Semantic Colors - Clear communication
  static const Color colorSuccess = Color(0xFF00D9A3); // Mint
  static const Color colorWarning = Color(0xFFFFB800); // Amber
  static const Color colorError = Color(0xFFFF4757); // Rose Red
  static const Color colorInfo = Color(0xFF4E9FF7); // Sky Blue

  // Neutral Colors - Refined grays
  static const Color neutral50 = Color(0xFFFAFBFC);
  static const Color neutral100 = Color(0xFFF5F7FA);
  static const Color neutral200 = Color(0xFFE9EDF2);
  static const Color neutral300 = Color(0xFFD2D9E0);
  static const Color neutral400 = Color(0xFFA3B2C3);
  static const Color neutral500 = Color(0xFF6B7A8C);
  static const Color neutral600 = Color(0xFF4A5568);
  static const Color neutral700 = Color(0xFF2D3748);
  static const Color neutral800 = Color(0xFF1A202C);
  static const Color neutral900 = Color(0xFF0F1419);

  // Background Colors - Subtle and elegant
  static const Color backgroundPrimary = Color(0xFFFBFCFE);
  static const Color backgroundSecondary = Colors.white;
  static const Color backgroundElevated = Color(0xFFFDFEFF);

  // Surface Colors for cards
  static const Color surfaceColor = Colors.white;
  static const Color surfaceColorDark = Color(0xFF1A202C);

  // ============================================
  // SPACING SYSTEM (8px base)
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
  static const double space9 = 36;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space14 = 56;
  static const double space16 = 64;
  static const double space20 = 80;

  // ============================================
  // CORNER RADIUS SYSTEM
  // ============================================
  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radius2xl = 28;
  static const double radius3xl = 32;
  static const double radiusFull = 999;

  // ============================================
  // TYPOGRAPHY SYSTEM - MODERN & ELEGANT
  // ============================================

  // Display - For hero sections
  static TextStyle displayLarge = GoogleFonts.plusJakartaSans(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    letterSpacing: -2,
    height: 1.1,
  );

  static TextStyle displayMedium = GoogleFonts.plusJakartaSans(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.plusJakartaSans(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    height: 1.2,
  );

  // Headlines - Section headers
  static TextStyle headlineLarge = GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle headlineMedium = GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle headlineSmall = GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  // Titles - Component headers
  static TextStyle titleLarge = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle titleMedium = GoogleFonts.plusJakartaSans(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
  );

  static TextStyle titleSmall = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
  );

  // Body - Content text
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.6,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.6,
  );

  // Labels - UI elements
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  // ============================================
  // MODERN ELEVATION SYSTEM
  // ============================================

  static List<BoxShadow> elevationLight = [
    BoxShadow(
      color: const Color(0xFF5B4CF5).withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevationMedium = [
    BoxShadow(
      color: const Color(0xFF5B4CF5).withOpacity(0.06),
      blurRadius: 40,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevationHigh = [
    BoxShadow(
      color: const Color(0xFF5B4CF5).withOpacity(0.08),
      blurRadius: 60,
      offset: const Offset(0, 16),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevationColored(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.25),
        blurRadius: 40,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: color.withOpacity(0.15),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }

  // ============================================
  // ANIMATION SYSTEM
  // ============================================

  // Durations - Refined for smoothness
  static const Duration durationQuick = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSmooth = Duration(milliseconds: 350);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationGentle = Duration(milliseconds: 750);

  // Curves - Natural movement
  static const Curve curveElegant = Curves.easeInOutCubic;
  static const Curve curveSmooth = Curves.easeOutQuart;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveGentle = Curves.easeInOutQuad;

  // ============================================
  // ICON SIZES
  // ============================================

  static const double iconSizeXs = 16;
  static const double iconSizeSm = 20;
  static const double iconSizeMd = 24;
  static const double iconSizeLg = 28;
  static const double iconSizeXl = 32;
  static const double iconSize2xl = 40;

  // ============================================
  // GRADIENTS
  // ============================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient subtleGradient(Color color) {
    return LinearGradient(
      colors: [color.withOpacity(0.8), color],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  // ============================================
  // BLUR EFFECTS
  // ============================================

  static const double blurLight = 8;
  static const double blurMedium = 16;
  static const double blurHeavy = 24;

  // ============================================
  // OPACITY LEVELS
  // ============================================

  static const double opacityFull = 1.0;
  static const double opacityHigh = 0.87;
  static const double opacityMedium = 0.60;
  static const double opacityLow = 0.38;
  static const double opacityVeryLow = 0.12;

  // ============================================
  // RESPONSIVE BREAKPOINTS
  // ============================================

  static const double breakpointMobile = 375;
  static const double breakpointTablet = 768;
  static const double breakpointDesktop = 1024;

  // ============================================
  // ADDITIONAL SHADOW CONSTANTS
  // ============================================

  // Shadows
  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 40,
      offset: const Offset(0, 8),
    ),
  ];

  // Semantic colors
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color successColor = Color(0xFF10B981);
}

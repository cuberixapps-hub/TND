import 'package:flutter/material.dart';

class AppColors {
  // Modern Gradient Combinations
  static const List<Color> primaryGradient = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFF093FB),
    Color(0xFFF5576C),
  ];

  static const List<Color> successGradient = [
    Color(0xFF00F260),
    Color(0xFF0575E6),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF4D03F),
    Color(0xFFE96443),
  ];

  // Mode Specific Gradients
  static const Map<String, List<Color>> modeGradients = {
    'kids': [Color(0xFF667EEA), Color(0xFF64B5F6)],
    'teens': [Color(0xFFE91E63), Color(0xFF9C27B0)],
    'adult': [Color(0xFFFF5252), Color(0xFFFF1744)],
    'couples': [Color(0xFFFF4081), Color(0xFFF50057)],
  };

  // Soft Pastels for Backgrounds
  static const Color softPink = Color(0xFFFFF0F5);
  static const Color softBlue = Color(0xFFF0F8FF);
  static const Color softPurple = Color(0xFFF8F0FF);
  static const Color softYellow = Color(0xFFFFFDF0);

  // Glassmorphism Colors
  static Color glassWhite = Colors.white.withOpacity(0.1);
  static Color glassBorder = Colors.white.withOpacity(0.2);

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 25,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/navigation/app_navigation.dart';
import '../../core/theme/design_system.dart';
import 'player_setup_screen.dart';
import 'settings_screen_v2.dart';
import 'custom_challenge_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set status bar style for clean look
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Clean light gray background
      body: SafeArea(
        child: Column(
          children: [
            // Settings icon in top-right
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        AppNavigation.navigateSlideFromRight(
                          context,
                          const SettingsScreenV2(),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          color: Color(0xFF374151),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: const Duration(milliseconds: 600)),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Logo and title section
                    _buildLogoSection(context),

                    const SizedBox(height: 60),

                    // Mode selection cards
                    Expanded(child: _buildModeGrid(context)),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppNavigation.navigateSlideFromBottom(
            context,
            const CustomChallengeScreen(),
          );
        },
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Challenge',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Column(
      children: [
        // App icon with subtle shadow
        Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎭', style: TextStyle(fontSize: 56)),
              ),
            )
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 600))
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: 24),

        // App title with elegant typography
        Text(
          'Truth or Dare',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 600),
        ),

        const SizedBox(height: 8),

        // Subtle tagline
        Text(
          'Choose your game mode',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            letterSpacing: 0,
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 600),
        ),
      ],
    );
  }

  Widget _buildModeGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: GameMode.values.length,
      itemBuilder: (context, index) {
        final mode = GameMode.values[index];
        return _buildModeCard(context, mode, index);
      },
    );
  }

  Widget _buildModeCard(BuildContext context, GameMode mode, int index) {
    // Define solid colors for each mode
    final modeData = {
      GameMode.kids: {
        'color': const Color(0xFF10B981),
        'icon': Icons.child_care_outlined,
      },
      GameMode.teens: {
        'color': const Color(0xFF3B82F6),
        'icon': Icons.celebration_outlined,
      },
      GameMode.adult: {
        'color': const Color(0xFFEF4444),
        'icon': Icons.local_fire_department_outlined,
      },
      GameMode.couples: {
        'color': const Color(0xFFEC4899),
        'icon': Icons.favorite_border,
      },
    };

    final data = modeData[mode]!;
    final color = data['color'] as Color;
    final icon = data['icon'] as IconData;

    return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _showModeAnimation(context, mode, color);
            },
            onTapDown: (_) => HapticFeedback.selectionClick(),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: null, // Handled by parent
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon container
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      const SizedBox(height: 16),
                      // Mode label
                      Text(
                        mode.label,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Mode description
                      Text(
                        _getModeSubtitle(mode),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 400 + (index * 100)),
          duration: const Duration(milliseconds: 500),
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: Duration(milliseconds: 400 + (index * 100)),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
  }

  String _getModeSubtitle(GameMode mode) {
    switch (mode) {
      case GameMode.kids:
        return 'Family friendly';
      case GameMode.teens:
        return 'Perfect for teens';
      case GameMode.adult:
        return 'Bold & daring';
      case GameMode.couples:
        return 'For two hearts';
    }
  }

  IconData _getModeIcon(GameMode mode) {
    switch (mode) {
      case GameMode.kids:
        return Icons.child_care_outlined;
      case GameMode.teens:
        return Icons.school_outlined;
      case GameMode.adult:
        return Icons.local_bar_outlined;
      case GameMode.couples:
        return Icons.favorite_outline;
    }
  }

  void _showModeAnimation(BuildContext context, GameMode mode, Color color) {
    // Show expanding circle animation
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child:
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getModeIcon(mode),
                      color: Colors.white,
                      size: 50,
                    ),
                  )
                  .animate()
                  .scale(
                    duration: DesignSystem.durationNormal,
                    curve: DesignSystem.curveEaseOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(10, 10),
                    duration: DesignSystem.durationNormal,
                    curve: DesignSystem.curveEaseIn,
                  )
                  .fadeOut(),
        );
      },
      transitionDuration: DesignSystem.durationVerySlow,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    );

    // Navigate after animation
    Future.delayed(DesignSystem.durationVerySlow, () {
      AppNavigation.navigateFade(context, PlayerSetupScreen(mode: mode));
    });
  }
}

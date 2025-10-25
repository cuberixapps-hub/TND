import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/design_system.dart';
import '../widgets/common_widgets.dart';
import 'player_setup_screen.dart';
import 'modern_settings_screen.dart';
import 'custom_challenge_screen.dart';

class HomeScreenV2 extends ConsumerWidget {
  const HomeScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: DesignSystem.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header with settings
            _buildHeader(context),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.space6,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: DesignSystem.space10),

                    // Logo and title
                    _buildLogoSection(context),

                    const SizedBox(height: DesignSystem.space16),

                    // Mode selection grid
                    _buildModeGrid(context),

                    const SizedBox(height: DesignSystem.space6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.space6,
            vertical: DesignSystem.space4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppIconButton(
                icon: Icons.settings_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    DesignSystem.slideTransition(page: const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: DesignSystem.durationNormal)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildLogoSection(BuildContext context) {
    return Column(
      children: [
        // App icon
        AppCard(
              padding: const EdgeInsets.all(DesignSystem.space6),
              backgroundColor: DesignSystem.backgroundSecondary,
              borderRadius: DesignSystem.radius2xl,
              child: Text(
                '🎭',
                style: DesignSystem.displayLarge.copyWith(fontSize: 56),
              ),
            )
            .animate()
            .fadeIn(duration: DesignSystem.durationVerySlow)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: DesignSystem.durationVerySlow,
              curve: DesignSystem.curveElasticOut,
            ),

        const SizedBox(height: DesignSystem.space6),

        // App title
        Text(
          'Truth or Dare',
          style: DesignSystem.displaySmall.copyWith(
            color: DesignSystem.neutral900,
          ),
        ).animate().fadeIn(
          delay: DesignSystem.durationFast,
          duration: DesignSystem.durationVerySlow,
        ),

        const SizedBox(height: DesignSystem.space2),

        // Subtitle
        Text(
          'Choose your adventure',
          style: DesignSystem.bodyLarge.copyWith(
            color: DesignSystem.neutral600,
          ),
        ).animate().fadeIn(
          delay: DesignSystem.durationNormal,
          duration: DesignSystem.durationVerySlow,
        ),
      ],
    );
  }

  Widget _buildModeGrid(BuildContext context) {
    final modes = [
      _ModeData(
        mode: GameMode.kids,
        icon: Icons.child_care_outlined,
        color: DesignSystem.colorKids,
        subtitle: 'Family friendly fun',
      ),
      _ModeData(
        mode: GameMode.teens,
        icon: Icons.school_outlined,
        color: DesignSystem.colorTeens,
        subtitle: 'Teen adventures',
      ),
      _ModeData(
        mode: GameMode.adult,
        icon: Icons.local_bar_outlined,
        color: DesignSystem.colorAdult,
        subtitle: 'Spicy challenges',
      ),
      _ModeData(
        mode: GameMode.couples,
        icon: Icons.favorite_outline,
        color: DesignSystem.colorCouples,
        subtitle: 'Romantic moments',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 400 ? 2 : 2;
        final aspectRatio = constraints.maxWidth > 400 ? 1.2 : 1.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: DesignSystem.space4,
            crossAxisSpacing: DesignSystem.space4,
            childAspectRatio: aspectRatio,
          ),
          itemCount: modes.length,
          itemBuilder: (context, index) {
            return _buildModeCard(context, modes[index], index);
          },
        );
      },
    );
  }

  Widget _buildModeCard(BuildContext context, _ModeData data, int index) {
    return GestureDetector(
          onTapDown: (_) => HapticFeedback.lightImpact(),
          onTap: () {
            _showModeAnimation(context, data);
          },
          child: AppCard(
            padding: const EdgeInsets.all(DesignSystem.space5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                  ),
                  child: Icon(
                    data.icon,
                    color: data.color,
                    size: DesignSystem.iconSizeLg,
                  ),
                ),

                const SizedBox(height: DesignSystem.space4),

                // Mode label
                Text(
                  data.mode.label,
                  style: DesignSystem.titleMedium.copyWith(
                    color: DesignSystem.neutral900,
                  ),
                ),

                const SizedBox(height: DesignSystem.space1),

                // Subtitle
                Text(
                  data.subtitle,
                  style: DesignSystem.caption.copyWith(
                    color: DesignSystem.neutral600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 400 + (index * 100)),
          duration: DesignSystem.durationSlow,
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          delay: Duration(milliseconds: 400 + (index * 100)),
          duration: DesignSystem.durationSlow,
          curve: DesignSystem.curveEaseOut,
        );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          DesignSystem.slideTransition(
            page: const CustomChallengeScreen(),
            beginOffset: const Offset(0.0, 1.0),
          ),
        );
      },
      backgroundColor: DesignSystem.primaryIndigo,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'Add Challenge',
        style: DesignSystem.labelLarge.copyWith(color: Colors.white),
      ),
    );
  }

  void _showModeAnimation(BuildContext context, _ModeData data) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child:
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: data.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 50),
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

    Future.delayed(DesignSystem.durationVerySlow, () {
      Navigator.push(
        context,
        DesignSystem.fadeTransition(page: PlayerSetupScreen(mode: data.mode)),
      );
    });
  }
}

class _ModeData {
  final GameMode mode;
  final IconData icon;
  final Color color;
  final String subtitle;

  _ModeData({
    required this.mode,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}

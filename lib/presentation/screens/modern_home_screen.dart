import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/modern_design_system.dart';
import '../../core/theme/app_icons.dart';
import '../../core/animations/modern_animations.dart';
import '../../core/navigation/app_navigation.dart';
import '../widgets/modern_components.dart';
import 'modern_player_setup_screen.dart';
import 'modern_settings_screen.dart';
import 'custom_challenge_screen.dart';

class ModernHomeScreen extends ConsumerStatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  ConsumerState<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends ConsumerState<ModernHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _modeController;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      duration: ModernDesignSystem.durationGentle,
      vsync: this,
    );
    _modeController = AnimationController(
      duration: ModernDesignSystem.durationSmooth,
      vsync: this,
    );

    _heroController.forward();
    Future.delayed(ModernDesignSystem.durationNormal, () {
      _modeController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _modeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundPrimary,
      body: Stack(
        children: [
          // Background decoration
          _buildBackground(size),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom app bar
                _buildAppBar(context),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ModernDesignSystem.space6,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: ModernDesignSystem.space8),

                          // Hero section
                          _buildHeroSection(context),

                          const SizedBox(height: ModernDesignSystem.space12),

                          // Game modes
                          _buildGameModes(context),

                          const SizedBox(height: ModernDesignSystem.space10),

                          // Quick actions
                          _buildQuickActions(context),

                          const SizedBox(height: ModernDesignSystem.space8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(Size size) {
    return Positioned(
      top: -size.height * 0.3,
      right: -size.width * 0.3,
      child:
          Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ModernDesignSystem.primaryLight.withOpacity(0.1),
                      ModernDesignSystem.primaryLight.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
              .animate()
              .scale(
                duration: ModernDesignSystem.durationGentle,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
              )
              .fadeIn(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ModernDesignSystem.space5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ModernDesignSystem.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusMd,
                  ),
                ),
                child: Center(
                  child: Text('🎭', style: ModernDesignSystem.headlineSmall),
                ),
              ),
              const SizedBox(width: ModernDesignSystem.space3),
              Text(
                'Truth or Dare',
                style: ModernDesignSystem.titleLarge.copyWith(
                  color: ModernDesignSystem.neutral900,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ).fadeScaleIn(),

          // Settings button
          Container(
            decoration: BoxDecoration(
              color: ModernDesignSystem.surfaceColor,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
              boxShadow: ModernDesignSystem.elevationLight,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  AppNavigation.navigateSlideFromRight(
                    context,
                    const ModernSettingsScreen(),
                  );
                },
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusMd,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(ModernDesignSystem.space3),
                  child: AppIcons.customIcon(
                    AppIcons.settings,
                    size: ModernDesignSystem.iconSizeMd,
                    color: ModernDesignSystem.neutral700,
                  ),
                ),
              ),
            ),
          ).fadeScaleIn(delay: ModernDesignSystem.durationQuick),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        return Opacity(
          opacity: _heroController.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _heroController.value)),
            child: Column(
              children: [
                Text(
                  'Ready for',
                  style: ModernDesignSystem.headlineMedium.copyWith(
                    color: ModernDesignSystem.neutral600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: ModernDesignSystem.space2),
                Text(
                  'Truth or Dare?',
                  style: ModernDesignSystem.displaySmall.copyWith(
                    color: ModernDesignSystem.neutral900,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: ModernDesignSystem.space4),
                Text(
                  'Choose your adventure and let the fun begin',
                  style: ModernDesignSystem.bodyLarge.copyWith(
                    color: ModernDesignSystem.neutral500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameModes(BuildContext context) {
    final modes = [
      _GameModeData(
        mode: GameMode.kids,
        title: 'Kids',
        subtitle: 'Safe & fun',
        icon: AppIcons.kids,
        color: ModernDesignSystem.colorKids,
        gradient: [
          ModernDesignSystem.colorKids,
          ModernDesignSystem.colorKids.withOpacity(0.7),
        ],
      ),
      _GameModeData(
        mode: GameMode.teens,
        title: 'Teens',
        subtitle: 'Exciting challenges',
        icon: AppIcons.teens,
        color: ModernDesignSystem.colorTeens,
        gradient: [
          ModernDesignSystem.colorTeens,
          ModernDesignSystem.colorTeens.withOpacity(0.7),
        ],
      ),
      _GameModeData(
        mode: GameMode.adult,
        title: 'Adult',
        subtitle: 'Spicy & bold',
        icon: AppIcons.adult,
        color: ModernDesignSystem.colorAdult,
        gradient: [
          ModernDesignSystem.colorAdult,
          ModernDesignSystem.colorAdult.withOpacity(0.7),
        ],
      ),
      _GameModeData(
        mode: GameMode.couples,
        title: 'Couples',
        subtitle: 'Romantic fun',
        icon: AppIcons.couples,
        color: ModernDesignSystem.colorCouples,
        gradient: [
          ModernDesignSystem.colorCouples,
          ModernDesignSystem.colorCouples.withOpacity(0.7),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Game Modes',
          style: ModernDesignSystem.headlineSmall.copyWith(
            color: ModernDesignSystem.neutral900,
          ),
        ).slideUpIn(),
        const SizedBox(height: ModernDesignSystem.space5),
        ...modes.asMap().entries.map((entry) {
          final index = entry.key;
          final mode = entry.value;
          return _buildModeCard(context, mode, index);
        }),
      ],
    );
  }

  Widget _buildModeCard(BuildContext context, _GameModeData data, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ModernDesignSystem.space4),
      child: ModernCard(
        onTap: () {
          HapticFeedback.lightImpact();
          _navigateToMode(context, data);
        },
        padding: EdgeInsets.zero,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
            gradient: LinearGradient(
              colors: data.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  data.icon,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ModernDesignSystem.space6,
                  vertical: ModernDesignSystem.space5,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radiusMd,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          data.icon,
                          color: Colors.white,
                          size: ModernDesignSystem.iconSizeLg,
                        ),
                      ),
                    ),
                    const SizedBox(width: ModernDesignSystem.space5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.title,
                          style: ModernDesignSystem.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: ModernDesignSystem.space1),
                        Text(
                          data.subtitle,
                          style: ModernDesignSystem.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: ModernDesignSystem.iconSizeSm,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).staggeredItem(index, baseDelay: ModernDesignSystem.durationNormal);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: ModernDesignSystem.headlineSmall.copyWith(
            color: ModernDesignSystem.neutral900,
          ),
        ).slideUpIn(delay: ModernDesignSystem.durationSmooth),
        const SizedBox(height: ModernDesignSystem.space5),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: AppIcons.add,
                title: 'Custom',
                subtitle: 'Create',
                color: ModernDesignSystem.primaryColor,
                onTap: () {
                  HapticFeedback.lightImpact();
                  AppNavigation.navigateSlideFromBottom(
                    context,
                    const CustomChallengeScreen(),
                  );
                },
              ),
            ),
            const SizedBox(width: ModernDesignSystem.space4),
            Expanded(
              child: _buildActionCard(
                icon: AppIcons.leaderboard,
                title: 'Stats',
                subtitle: 'History',
                color: ModernDesignSystem.secondaryColor,
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to stats
                },
              ),
            ),
          ],
        ).slideUpIn(delay: ModernDesignSystem.durationSlow),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ModernCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: ModernDesignSystem.iconSizeMd,
              ),
            ),
          ),
          const SizedBox(height: ModernDesignSystem.space4),
          Text(
            title,
            style: ModernDesignSystem.titleMedium.copyWith(
              color: ModernDesignSystem.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: ModernDesignSystem.space1),
          Text(
            subtitle,
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMode(BuildContext context, _GameModeData data) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child:
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: data.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 60),
                  )
                  .animate()
                  .scale(
                    duration: ModernDesignSystem.durationNormal,
                    curve: ModernDesignSystem.curveBounce,
                  )
                  .then(delay: ModernDesignSystem.durationQuick)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(8, 8),
                    duration: ModernDesignSystem.durationNormal,
                  )
                  .fadeOut(),
        );
      },
      transitionDuration: ModernDesignSystem.durationSmooth,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    );

    Future.delayed(ModernDesignSystem.durationSmooth, () {
      AppNavigation.navigateFade(
        context,
        ModernPlayerSetupScreen(mode: data.mode),
      );
    });
  }
}

class _GameModeData {
  final GameMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  const _GameModeData({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

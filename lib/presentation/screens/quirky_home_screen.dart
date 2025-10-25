import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../core/constants/app_constants.dart';
import '../../core/theme/modern_design_system.dart';
import '../../core/theme/app_icons.dart';
import '../../core/animations/modern_animations.dart';
import '../../core/navigation/app_navigation.dart';
import '../widgets/banner_ad_widget.dart';
import 'modern_player_setup_screen.dart';
import 'modern_settings_screen.dart';
import 'custom_challenge_screen.dart';
import 'stats_screen.dart';

class QuirkyHomeScreen extends ConsumerStatefulWidget {
  const QuirkyHomeScreen({super.key});

  @override
  ConsumerState<QuirkyHomeScreen> createState() => _QuirkyHomeScreenState();
}

class _QuirkyHomeScreenState extends ConsumerState<QuirkyHomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _heroController;
  late AnimationController _modeController;
  late AnimationController _wobbleController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _heroController = AnimationController(
      duration: ModernDesignSystem.durationGentle,
      vsync: this,
    );
    _modeController = AnimationController(
      duration: ModernDesignSystem.durationSmooth,
      vsync: this,
    );
    _wobbleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _heroController.forward();
    Future.delayed(ModernDesignSystem.durationNormal, () {
      if (mounted) {
        _modeController.forward();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _heroController.dispose();
    _modeController.dispose();
    _wobbleController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Force rebuild when app comes to foreground
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundPrimary,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernDesignSystem.backgroundPrimary,
              ModernDesignSystem.primaryLight.withOpacity(0.05),
              ModernDesignSystem.secondaryLight.withOpacity(0.05),
              ModernDesignSystem.backgroundPrimary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // App bar
              _buildQuirkyAppBar(context),

              // Main scrollable content
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: ModernDesignSystem.space6,
                    right: ModernDesignSystem.space6,
                    bottom: 100 + MediaQuery.of(context).padding.bottom,
                  ),
                  children: [
                    const SizedBox(height: ModernDesignSystem.space8),

                    // Hero section with quirky animation
                    _buildQuirkyHeroSection(context),

                    const SizedBox(height: ModernDesignSystem.space12),

                    // Game modes with fun animations
                    _buildQuirkyGameModes(context),

                    const SizedBox(height: ModernDesignSystem.space10),

                    // Quick actions with bounce
                    _buildQuirkyQuickActions(context),

                    const SizedBox(height: ModernDesignSystem.space8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(top: false, child: BannerAdWidget()),
    );
  }

  Widget _buildQuirkyAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ModernDesignSystem.space5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo with wobble animation
          AnimatedBuilder(
            animation: _wobbleController,
            builder: (context, child) {
              return Transform.rotate(
                angle: math.sin(_wobbleController.value * 2 * math.pi) * 0.1,
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radiusMd,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ModernDesignSystem.primaryColor.withOpacity(
                              0.3,
                            ),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radiusMd,
                        ),
                        child: Image.asset(
                          'app_icon.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: ModernDesignSystem.space3),
                    Text(
                      'Truth or Dare',
                      style: ModernDesignSystem.titleLarge.copyWith(
                        color: ModernDesignSystem.neutral900,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ).fadeScaleIn(),

          // Settings button with rotation
          Transform.rotate(
                angle: -0.1,
                child: Container(
                  decoration: BoxDecoration(
                    color: ModernDesignSystem.surfaceColor,
                    borderRadius: BorderRadius.circular(
                      ModernDesignSystem.radiusMd,
                    ),
                    boxShadow: ModernDesignSystem.elevationMedium,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      ModernDesignSystem.radiusMd,
                    ),
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
                        padding: const EdgeInsets.all(
                          ModernDesignSystem.space3,
                        ),
                        child: AppIcons.customIcon(
                          AppIcons.settings,
                          size: ModernDesignSystem.iconSizeMd,
                          color: ModernDesignSystem.neutral700,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .rotate(duration: ModernDesignSystem.durationSlow, end: 0.1)
              .fadeIn(),
        ],
      ),
    );
  }

  Widget _buildQuirkyHeroSection(BuildContext context) {
    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        return Opacity(
          opacity: _heroController.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _heroController.value)),
            child: Column(
              children: [
                // Animated welcome text
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: [
                          ModernDesignSystem.primaryColor,
                          ModernDesignSystem.secondaryColor,
                          ModernDesignSystem.primaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                  child: Text(
                    'Ready for',
                    style: ModernDesignSystem.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: ModernDesignSystem.space2),

                // Main title with bounce
                Text(
                      'Truth or Dare?',
                      style: ModernDesignSystem.displaySmall.copyWith(
                        color: ModernDesignSystem.neutral900,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    )
                    .animate()
                    .scale(
                      delay: ModernDesignSystem.durationQuick,
                      duration: ModernDesignSystem.durationNormal,
                      curve: Curves.elasticOut,
                    )
                    .shimmer(
                      delay: ModernDesignSystem.durationSlow,
                      duration: const Duration(seconds: 2),
                      color: ModernDesignSystem.primaryLight.withOpacity(0.3),
                    ),

                const SizedBox(height: ModernDesignSystem.space4),

                // Subtitle with typewriter effect
                Text(
                      'Choose your adventure and let the fun begin',
                      style: ModernDesignSystem.bodyLarge.copyWith(
                        color: ModernDesignSystem.neutral500,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(delay: ModernDesignSystem.durationNormal)
                    .slideX(begin: -0.1, end: 0),

                const SizedBox(height: ModernDesignSystem.space4),

                // Fun emoji row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      ['🎲', '🎯', '🎪', '🎉']
                          .asMap()
                          .entries
                          .map(
                            (entry) => Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 24),
                                )
                                .animate()
                                .scale(
                                  delay: Duration(
                                    milliseconds: 200 + entry.key * 100,
                                  ),
                                  duration: ModernDesignSystem.durationNormal,
                                  curve: Curves.elasticOut,
                                )
                                .rotate(
                                  delay: Duration(
                                    milliseconds: 200 + entry.key * 100,
                                  ),
                                  duration: ModernDesignSystem.durationNormal,
                                ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuirkyGameModes(BuildContext context) {
    final modes = [
      _GameModeData(
        mode: GameMode.kids,
        title: 'Kids',
        subtitle: 'Safe & silly fun',
        icon: AppIcons.kids,
        emoji: '🦄',
        color: ModernDesignSystem.colorKids,
        gradient: [
          ModernDesignSystem.colorKids,
          ModernDesignSystem.colorKids.withOpacity(0.6),
        ],
        rotation: -0.05,
      ),
      _GameModeData(
        mode: GameMode.teens,
        title: 'Teens',
        subtitle: 'Wild adventures',
        icon: AppIcons.teens,
        emoji: '🚀',
        color: ModernDesignSystem.colorTeens,
        gradient: [
          ModernDesignSystem.colorTeens,
          ModernDesignSystem.colorTeens.withOpacity(0.6),
        ],
        rotation: 0.05,
      ),
      _GameModeData(
        mode: GameMode.adult,
        title: 'Adult',
        subtitle: 'Spicy & daring',
        icon: AppIcons.adult,
        emoji: '🔥',
        color: ModernDesignSystem.colorAdult,
        gradient: [
          ModernDesignSystem.colorAdult,
          ModernDesignSystem.colorAdult.withOpacity(0.6),
        ],
        rotation: -0.03,
      ),
      _GameModeData(
        mode: GameMode.couples,
        title: 'Couples',
        subtitle: 'Love & laughs',
        icon: AppIcons.couples,
        emoji: '💕',
        color: ModernDesignSystem.colorCouples,
        gradient: [
          ModernDesignSystem.colorCouples,
          ModernDesignSystem.colorCouples.withOpacity(0.6),
        ],
        rotation: 0.03,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pick Your',
              style: ModernDesignSystem.headlineSmall.copyWith(
                color: ModernDesignSystem.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: ModernDesignSystem.space2),
            Text(
              'Vibe',
              style: ModernDesignSystem.headlineSmall.copyWith(
                color: ModernDesignSystem.primaryColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: ModernDesignSystem.space2),
            Text('✨', style: const TextStyle(fontSize: 24))
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: const Duration(seconds: 2))
                .shimmer(duration: const Duration(seconds: 2)),
          ],
        ).slideUpIn(),
        const SizedBox(height: ModernDesignSystem.space5),
        ...modes.asMap().entries.map((entry) {
          final index = entry.key;
          final mode = entry.value;
          return _buildQuirkyModeCard(context, mode, index);
        }),
      ],
    );
  }

  Widget _buildQuirkyModeCard(
    BuildContext context,
    _GameModeData data,
    int index,
  ) {
    return Padding(
          padding: const EdgeInsets.only(bottom: ModernDesignSystem.space4),
          child: Transform.rotate(
            angle: data.rotation,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radius2xl,
                ),
                gradient: LinearGradient(
                  colors: data.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.color.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radius2xl,
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _navigateToMode(context, data);
                  },
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radius2xl,
                  ),
                  child: Stack(
                    children: [
                      // Floating emoji background
                      Positioned(
                        right: 20,
                        top: -10,
                        child: Transform.rotate(
                          angle: 0.3,
                          child: Text(
                            data.emoji,
                            style: TextStyle(
                              fontSize: 80,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
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
                            // Icon container with wobble
                            AnimatedBuilder(
                              animation: _wobbleController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale:
                                      1 +
                                      math.sin(
                                            _wobbleController.value *
                                                    2 *
                                                    math.pi +
                                                index,
                                          ) *
                                          0.05,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        data.icon,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: ModernDesignSystem.space5),

                            // Text content
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  data.title,
                                  style: ModernDesignSystem.headlineSmall
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                const SizedBox(
                                  height: ModernDesignSystem.space1,
                                ),
                                Text(
                                  data.subtitle,
                                  style: ModernDesignSystem.bodySmall.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),

                            const Spacer(),

                            // Animated arrow
                            Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .moveX(
                                  begin: 0,
                                  end: 5,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                )
                                .then()
                                .moveX(
                                  begin: 5,
                                  end: 0,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .slideX(
          begin: index.isEven ? -0.2 : 0.2,
          end: 0,
          delay: Duration(milliseconds: 200 + index * 100),
          duration: ModernDesignSystem.durationSmooth,
          curve: Curves.elasticOut,
        )
        .fadeIn(delay: Duration(milliseconds: 200 + index * 100));
  }

  Widget _buildQuirkyQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'More Fun',
              style: ModernDesignSystem.headlineSmall.copyWith(
                color: ModernDesignSystem.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: ModernDesignSystem.space2),
            Text('🎉', style: const TextStyle(fontSize: 24))
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  end: const Offset(1.2, 1.2),
                  duration: const Duration(milliseconds: 500),
                ),
          ],
        ).slideUpIn(delay: ModernDesignSystem.durationSmooth),
        const SizedBox(height: ModernDesignSystem.space5),
        Row(
          children: [
            Expanded(
              child: _buildQuirkyActionCard(
                icon: AppIcons.add,
                emoji: '✏️',
                title: 'Create',
                subtitle: 'Custom dares',
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
              child: _buildQuirkyActionCard(
                icon: AppIcons.leaderboard,
                emoji: '📊',
                title: 'Stats',
                subtitle: 'Your records',
                color: ModernDesignSystem.secondaryColor,
                onTap: () {
                  HapticFeedback.lightImpact();
                  AppNavigation.navigateSlideFromBottom(
                    context,
                    const StatsScreen(),
                  );
                },
              ),
            ),
          ],
        ).slideUpIn(delay: ModernDesignSystem.durationSlow),
      ],
    );
  }

  Widget _buildQuirkyActionCard({
    required IconData icon,
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 165,
      decoration: BoxDecoration(
        color: ModernDesignSystem.surfaceColor,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radius2xl),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radius2xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ModernDesignSystem.radius2xl),
          child: Padding(
            padding: const EdgeInsets.all(ModernDesignSystem.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji with background
                Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Icon(icon, color: color, size: 24),
                          ),
                        ),
                        Positioned(
                          right: -3,
                          top: -3,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: ModernDesignSystem.surfaceColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .rotate(
                      begin: -0.05,
                      end: 0.05,
                      duration: const Duration(seconds: 2),
                    ),
                const SizedBox(height: ModernDesignSystem.space3),
                Text(
                  title,
                  style: ModernDesignSystem.titleMedium.copyWith(
                    color: ModernDesignSystem.neutral900,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: ModernDesignSystem.bodySmall.copyWith(
                    color: ModernDesignSystem.neutral500,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(
      delay: ModernDesignSystem.durationNormal,
      duration: ModernDesignSystem.durationSmooth,
      curve: Curves.elasticOut,
    );
  }

  void _navigateToMode(BuildContext context, _GameModeData data) {
    // Show fun transition
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child:
              Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: data.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: data.color.withOpacity(0.5),
                          blurRadius: 50,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        data.emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  )
                  .animate()
                  .scale(
                    duration: ModernDesignSystem.durationNormal,
                    curve: Curves.elasticOut,
                  )
                  .rotate(duration: ModernDesignSystem.durationNormal, end: 1)
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
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  ModernPlayerSetupScreen(mode: data.mode),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    });
  }
}

class _GameModeData {
  final GameMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final String emoji;
  final Color color;
  final List<Color> gradient;
  final double rotation;

  const _GameModeData({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emoji,
    required this.color,
    required this.gradient,
    required this.rotation,
  });
}

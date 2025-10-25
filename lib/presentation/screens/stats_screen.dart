import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/modern_design_system.dart';
import '../../core/theme/app_icons.dart';
import '../../core/navigation/app_navigation.dart';
import '../providers/stats_provider.dart';
import '../widgets/modern_components.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _chartController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernDesignSystem.durationSmooth,
      vsync: this,
    )..forward();

    _chartController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundPrimary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernDesignSystem.backgroundPrimary,
              ModernDesignSystem.primaryLight.withOpacity(0.03),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Content
              Expanded(
                child:
                    stats.totalGamesPlayed == 0
                        ? _buildEmptyState()
                        : _buildStatsContent(stats),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ModernDesignSystem.space5),
      child: Row(
        children: [
          // Back button
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
                  AppNavigation.pop(context);
                },
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusMd,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(ModernDesignSystem.space3),
                  child: Icon(
                    AppIcons.back,
                    color: ModernDesignSystem.neutral700,
                    size: ModernDesignSystem.iconSizeMd,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: ModernDesignSystem.space4),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game Statistics',
                  style: ModernDesignSystem.headlineMedium.copyWith(
                    color: ModernDesignSystem.neutral900,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Your Truth or Dare journey',
                  style: ModernDesignSystem.bodySmall.copyWith(
                    color: ModernDesignSystem.neutral600,
                  ),
                ),
              ],
            ),
          ),

          // Trophy icon
          Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 24)),
                ),
              )
              .animate()
              .scale(delay: ModernDesignSystem.durationQuick)
              .rotate(duration: ModernDesignSystem.durationSmooth),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ModernDesignSystem.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: ModernDesignSystem.primaryLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('📊', style: TextStyle(fontSize: 60)),
                  ),
                )
                .animate()
                .scale(
                  duration: ModernDesignSystem.durationNormal,
                  curve: Curves.elasticOut,
                )
                .fadeIn(),

            const SizedBox(height: ModernDesignSystem.space6),

            Text(
              'No Games Yet',
              style: ModernDesignSystem.headlineSmall.copyWith(
                color: ModernDesignSystem.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: ModernDesignSystem.space3),

            Text(
              'Start playing to see your statistics here!',
              style: ModernDesignSystem.bodyLarge.copyWith(
                color: ModernDesignSystem.neutral600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ModernDesignSystem.space8),

            ModernButton(
              label: 'Start Playing',
              icon: AppIcons.play,
              onPressed: () {
                HapticFeedback.lightImpact();
                AppNavigation.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent(GameStats stats) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(ModernDesignSystem.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          _buildOverviewSection(stats),

          const SizedBox(height: ModernDesignSystem.space8),

          // Challenge breakdown
          _buildChallengeBreakdown(stats),

          const SizedBox(height: ModernDesignSystem.space8),

          // Mode preferences
          _buildModePreferences(stats),

          const SizedBox(height: ModernDesignSystem.space8),

          // Achievements
          _buildAchievements(stats),

          const SizedBox(height: ModernDesignSystem.space8),

          // Fun facts
          _buildFunFacts(stats),

          const SizedBox(height: ModernDesignSystem.space8),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(GameStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: ModernDesignSystem.titleLarge.copyWith(
            color: ModernDesignSystem.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),

        const SizedBox(height: ModernDesignSystem.space5),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Games Played',
                value: stats.totalGamesPlayed.toString(),
                icon: AppIcons.play,
                color: ModernDesignSystem.primaryColor,
                delay: 0,
              ),
            ),
            const SizedBox(width: ModernDesignSystem.space4),
            Expanded(
              child: _buildStatCard(
                title: 'Total Players',
                value: stats.totalPlayers.toString(),
                icon: AppIcons.team,
                color: ModernDesignSystem.secondaryColor,
                delay: 100,
              ),
            ),
          ],
        ),

        const SizedBox(height: ModernDesignSystem.space4),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Challenges',
                value: stats.totalChallenges.toString(),
                icon: AppIcons.challenge,
                color: ModernDesignSystem.colorSuccess,
                delay: 200,
              ),
            ),
            const SizedBox(width: ModernDesignSystem.space4),
            Expanded(
              child: _buildStatCard(
                title: 'Win Rate',
                value: '${stats.averageWinRate.toStringAsFixed(0)}%',
                icon: AppIcons.trophy,
                color: ModernDesignSystem.colorWarning,
                delay: 300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return Container(
          padding: const EdgeInsets.all(ModernDesignSystem.space5),
          decoration: BoxDecoration(
            color: ModernDesignSystem.surfaceColor,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            boxShadow: ModernDesignSystem.elevationLight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusSm,
                  ),
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
                value,
                style: ModernDesignSystem.headlineSmall.copyWith(
                  color: ModernDesignSystem.neutral900,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: ModernDesignSystem.space1),
              Text(
                title,
                style: ModernDesignSystem.labelMedium.copyWith(
                  color: ModernDesignSystem.neutral600,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildChallengeBreakdown(GameStats stats) {
    final total = stats.truthsCompleted + stats.daresCompleted;
    final truthPercentage = total > 0 ? (stats.truthsCompleted / total) : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Challenge Breakdown',
              style: ModernDesignSystem.titleLarge.copyWith(
                color: ModernDesignSystem.neutral900,
                fontWeight: FontWeight.w700,
              ),
            )
            .animate()
            .fadeIn(delay: ModernDesignSystem.durationQuick)
            .slideY(begin: 0.1, end: 0),

        const SizedBox(height: ModernDesignSystem.space5),

        Container(
              padding: const EdgeInsets.all(ModernDesignSystem.space6),
              decoration: BoxDecoration(
                color: ModernDesignSystem.surfaceColor,
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusXl,
                ),
                boxShadow: ModernDesignSystem.elevationMedium,
              ),
              child: Column(
                children: [
                  // Visual bar chart
                  AnimatedBuilder(
                    animation: _chartController,
                    builder: (context, child) {
                      return Row(
                        children: [
                          // Truth bar
                          Expanded(
                            flex: (truthPercentage * 100).toInt(),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF4E9FF7),
                                    const Color(0xFF3B82F6),
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                    ModernDesignSystem.radiusMd,
                                  ),
                                  bottomLeft: Radius.circular(
                                    ModernDesignSystem.radiusMd,
                                  ),
                                  topRight:
                                      truthPercentage == 1
                                          ? Radius.circular(
                                            ModernDesignSystem.radiusMd,
                                          )
                                          : Radius.zero,
                                  bottomRight:
                                      truthPercentage == 1
                                          ? Radius.circular(
                                            ModernDesignSystem.radiusMd,
                                          )
                                          : Radius.zero,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'TRUTH',
                                  style: ModernDesignSystem.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Dare bar
                          if (truthPercentage < 1)
                            Expanded(
                              flex: ((1 - truthPercentage) * 100).toInt(),
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ModernDesignSystem.secondaryColor,
                                      ModernDesignSystem.secondaryDark,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(
                                      ModernDesignSystem.radiusMd,
                                    ),
                                    bottomRight: Radius.circular(
                                      ModernDesignSystem.radiusMd,
                                    ),
                                    topLeft:
                                        truthPercentage == 0
                                            ? Radius.circular(
                                              ModernDesignSystem.radiusMd,
                                            )
                                            : Radius.zero,
                                    bottomLeft:
                                        truthPercentage == 0
                                            ? Radius.circular(
                                              ModernDesignSystem.radiusMd,
                                            )
                                            : Radius.zero,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'DARE',
                                    style: ModernDesignSystem.labelLarge
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: ModernDesignSystem.space6),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildChallengeStatItem(
                        label: 'Truths',
                        value: stats.truthsCompleted,
                        icon: '🗣️',
                        color: const Color(0xFF4E9FF7),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: ModernDesignSystem.neutral200,
                      ),
                      _buildChallengeStatItem(
                        label: 'Dares',
                        value: stats.daresCompleted,
                        icon: '🎯',
                        color: ModernDesignSystem.secondaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: ModernDesignSystem.durationNormal)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
      ],
    );
  }

  Widget _buildChallengeStatItem({
    required String label,
    required int value,
    required String icon,
    required Color color,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: ModernDesignSystem.space2),
        Text(
          value.toString(),
          style: ModernDesignSystem.headlineMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: ModernDesignSystem.labelMedium.copyWith(
            color: ModernDesignSystem.neutral600,
          ),
        ),
      ],
    );
  }

  Widget _buildModePreferences(GameStats stats) {
    final modes = [
      _ModeData(
        'Kids',
        stats.kidsGamesPlayed,
        ModernDesignSystem.colorKids,
        '🦄',
      ),
      _ModeData(
        'Teens',
        stats.teensGamesPlayed,
        ModernDesignSystem.colorTeens,
        '🚀',
      ),
      _ModeData(
        'Adult',
        stats.adultGamesPlayed,
        ModernDesignSystem.colorAdult,
        '🔥',
      ),
      _ModeData(
        'Couples',
        stats.couplesGamesPlayed,
        ModernDesignSystem.colorCouples,
        '💕',
      ),
    ];

    modes.sort((a, b) => b.count.compareTo(a.count));
    final favoriteMode = modes.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Mode Preferences',
              style: ModernDesignSystem.titleLarge.copyWith(
                color: ModernDesignSystem.neutral900,
                fontWeight: FontWeight.w700,
              ),
            )
            .animate()
            .fadeIn(delay: ModernDesignSystem.durationSmooth)
            .slideY(begin: 0.1, end: 0),

        const SizedBox(height: ModernDesignSystem.space5),

        // Favorite mode highlight
        if (favoriteMode.count > 0)
          Container(
                padding: const EdgeInsets.all(ModernDesignSystem.space5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      favoriteMode.color.withOpacity(0.1),
                      favoriteMode.color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusLg,
                  ),
                  border: Border.all(
                    color: favoriteMode.color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      favoriteMode.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: ModernDesignSystem.space4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Favorite Mode',
                            style: ModernDesignSystem.labelLarge.copyWith(
                              color: favoriteMode.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            favoriteMode.name,
                            style: ModernDesignSystem.headlineSmall.copyWith(
                              color: ModernDesignSystem.neutral900,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ModernDesignSystem.space4,
                        vertical: ModernDesignSystem.space2,
                      ),
                      decoration: BoxDecoration(
                        color: favoriteMode.color,
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radiusFull,
                        ),
                      ),
                      child: Text(
                        '${favoriteMode.count} games',
                        style: ModernDesignSystem.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: ModernDesignSystem.durationSlow)
              .slideX(begin: -0.05, end: 0),

        const SizedBox(height: ModernDesignSystem.space4),

        // All modes
        ...modes.asMap().entries.map((entry) {
          final index = entry.key;
          final mode = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: ModernDesignSystem.space3),
            child: _buildModeStatBar(mode, stats.totalGamesPlayed, index),
          );
        }),
      ],
    );
  }

  Widget _buildModeStatBar(_ModeData mode, int total, int index) {
    final percentage = total > 0 ? (mode.count / total) : 0.0;

    return Container(
          padding: const EdgeInsets.all(ModernDesignSystem.space4),
          decoration: BoxDecoration(
            color: ModernDesignSystem.surfaceColor,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
            boxShadow: ModernDesignSystem.elevationLight,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(mode.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: ModernDesignSystem.space3),
                  Text(
                    mode.name,
                    style: ModernDesignSystem.titleSmall.copyWith(
                      color: ModernDesignSystem.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${mode.count}',
                    style: ModernDesignSystem.titleSmall.copyWith(
                      color: mode.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ModernDesignSystem.space3),
              // Progress bar
              AnimatedBuilder(
                animation: _chartController,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(
                      ModernDesignSystem.radiusFull,
                    ),
                    child: LinearProgressIndicator(
                      value: percentage * _chartController.value,
                      minHeight: 8,
                      backgroundColor: mode.color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(mode.color),
                    ),
                  );
                },
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 400 + index * 100))
        .slideX(begin: 0.05, end: 0);
  }

  Widget _buildAchievements(GameStats stats) {
    final achievements = _getAchievements(stats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Achievements',
              style: ModernDesignSystem.titleLarge.copyWith(
                color: ModernDesignSystem.neutral900,
                fontWeight: FontWeight.w700,
              ),
            )
            .animate()
            .fadeIn(delay: ModernDesignSystem.durationGentle)
            .slideY(begin: 0.1, end: 0),

        const SizedBox(height: ModernDesignSystem.space5),

        Wrap(
          spacing: ModernDesignSystem.space3,
          runSpacing: ModernDesignSystem.space3,
          children:
              achievements.asMap().entries.map((entry) {
                final index = entry.key;
                final achievement = entry.value;
                return _buildAchievementBadge(achievement, index);
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(_Achievement achievement, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ModernDesignSystem.space4,
        vertical: ModernDesignSystem.space3,
      ),
      decoration: BoxDecoration(
        gradient:
            achievement.earned
                ? LinearGradient(
                  colors: [
                    achievement.color,
                    achievement.color.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: achievement.earned ? null : ModernDesignSystem.neutral200,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusFull),
        boxShadow:
            achievement.earned
                ? [
                  BoxShadow(
                    color: achievement.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(
              fontSize: 20,
              color: achievement.earned ? null : ModernDesignSystem.neutral400,
            ),
          ),
          const SizedBox(width: ModernDesignSystem.space2),
          Text(
            achievement.title,
            style: ModernDesignSystem.labelLarge.copyWith(
              color:
                  achievement.earned
                      ? Colors.white
                      : ModernDesignSystem.neutral500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().scale(
      delay: Duration(milliseconds: 600 + index * 50),
      duration: ModernDesignSystem.durationNormal,
      curve: Curves.elasticOut,
    );
  }

  Widget _buildFunFacts(GameStats stats) {
    final facts = _generateFunFacts(stats);
    if (facts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Fun Facts',
              style: ModernDesignSystem.titleLarge.copyWith(
                color: ModernDesignSystem.neutral900,
                fontWeight: FontWeight.w700,
              ),
            )
            .animate()
            .fadeIn(delay: ModernDesignSystem.durationSlow)
            .slideY(begin: 0.1, end: 0),

        const SizedBox(height: ModernDesignSystem.space5),

        ...facts.asMap().entries.map((entry) {
          final index = entry.key;
          final fact = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: ModernDesignSystem.space3),
            child: _buildFunFactCard(fact, index),
          );
        }),
      ],
    );
  }

  Widget _buildFunFactCard(String fact, int index) {
    return Container(
          padding: const EdgeInsets.all(ModernDesignSystem.space5),
          decoration: BoxDecoration(
            color: ModernDesignSystem.surfaceColor,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
            border: Border.all(
              color: ModernDesignSystem.primaryLight.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: ModernDesignSystem.elevationLight,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ModernDesignSystem.primaryLight.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('💡', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: ModernDesignSystem.space4),
              Expanded(
                child: Text(
                  fact,
                  style: ModernDesignSystem.bodyMedium.copyWith(
                    color: ModernDesignSystem.neutral700,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 800 + index * 100))
        .slideY(begin: 0.05, end: 0);
  }

  List<_Achievement> _getAchievements(GameStats stats) {
    return [
      _Achievement(
        '🎮',
        'First Game',
        ModernDesignSystem.colorSuccess,
        stats.totalGamesPlayed >= 1,
      ),
      _Achievement(
        '🔟',
        '10 Games',
        ModernDesignSystem.primaryColor,
        stats.totalGamesPlayed >= 10,
      ),
      _Achievement(
        '💯',
        '100 Challenges',
        ModernDesignSystem.secondaryColor,
        stats.totalChallenges >= 100,
      ),
      _Achievement(
        '🏆',
        'Champion',
        const Color(0xFFFFD700),
        stats.totalWins >= 5,
      ),
      _Achievement(
        '🎯',
        'Dare Devil',
        ModernDesignSystem.colorAdult,
        stats.daresCompleted >= 50,
      ),
      _Achievement(
        '🗣️',
        'Truth Teller',
        const Color(0xFF4E9FF7),
        stats.truthsCompleted >= 50,
      ),
    ];
  }

  List<String> _generateFunFacts(GameStats stats) {
    final facts = <String>[];

    if (stats.totalChallenges > 0) {
      final truthPercentage =
          (stats.truthsCompleted / stats.totalChallenges * 100).toInt();
      if (truthPercentage > 60) {
        facts.add(
          'You prefer truths over dares! ${truthPercentage}% of your challenges were truths.',
        );
      } else if (truthPercentage < 40) {
        facts.add(
          'You\'re a daredevil! Only ${truthPercentage}% of your challenges were truths.',
        );
      }
    }

    if (stats.longestStreak > 5) {
      facts.add(
        'Your longest winning streak was ${stats.longestStreak} games in a row! 🔥',
      );
    }

    if (stats.totalGamesPlayed > 0) {
      final avgPlayersPerGame = (stats.totalPlayers / stats.totalGamesPlayed)
          .toStringAsFixed(1);
      facts.add(
        'You play with an average of $avgPlayersPerGame players per game.',
      );
    }

    return facts;
  }
}

class _ModeData {
  final String name;
  final int count;
  final Color color;
  final String emoji;

  _ModeData(this.name, this.count, this.color, this.emoji);
}

class _Achievement {
  final String icon;
  final String title;
  final Color color;
  final bool earned;

  _Achievement(this.icon, this.title, this.color, this.earned);
}

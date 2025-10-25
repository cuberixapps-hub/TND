import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/theme/modern_design_system.dart';
import '../../core/theme/app_icons.dart';
import '../../core/navigation/app_navigation.dart';
import '../../core/extensions/enum_extensions.dart';
import '../../data/models/player_model.dart';
import '../providers/game_provider.dart';
import '../widgets/modern_components.dart';
import '../widgets/banner_ad_widget.dart';

class ModernScoreboardScreen extends ConsumerStatefulWidget {
  const ModernScoreboardScreen({super.key});

  @override
  ConsumerState<ModernScoreboardScreen> createState() =>
      _ModernScoreboardScreenState();
}

class _ModernScoreboardScreenState extends ConsumerState<ModernScoreboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernDesignSystem.durationGentle,
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'kids':
        return ModernDesignSystem.colorKids;
      case 'teens':
        return ModernDesignSystem.colorTeens;
      case 'adult':
        return ModernDesignSystem.colorAdult;
      case 'couples':
        return ModernDesignSystem.colorCouples;
      default:
        return ModernDesignSystem.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final leaderboard = ref.watch(leaderboardProvider);

    if (gameState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final modeColor = _getModeColor(gameState.mode.enumName);
    final totalChallenges = gameState.players.fold<int>(
      0,
      (int sum, Player player) =>
          sum + player.truthsCompleted + player.daresCompleted,
    );
    final totalSkips = gameState.players.fold<int>(
      0,
      (int sum, Player player) => sum + player.skips,
    );

    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundPrimary,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -200,
            right: -200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    modeColor.withOpacity(0.1),
                    modeColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(ModernDesignSystem.space6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Leaderboard
                        _buildLeaderboard(leaderboard, modeColor),

                        const SizedBox(height: ModernDesignSystem.space10),

                        // Statistics
                        _buildStatistics(
                          gameState,
                          totalChallenges,
                          totalSkips,
                          modeColor,
                        ),

                        const SizedBox(height: ModernDesignSystem.space10),

                        // Action button
                        _buildActionButton(context, gameState.isActive),

                        const SizedBox(height: ModernDesignSystem.space8),

                        // Native Banner Ad
                        const NativeBannerAdWidget(),
                      ],
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
            child: Text(
              'Scoreboard',
              style: ModernDesignSystem.headlineMedium.copyWith(
                color: ModernDesignSystem.neutral900,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildLeaderboard(List<Player> leaderboard, Color modeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rankings',
          style: ModernDesignSystem.headlineSmall.copyWith(
            color: ModernDesignSystem.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(),

        const SizedBox(height: ModernDesignSystem.space5),

        ...leaderboard.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          return _buildPlayerRankCard(player, index + 1, modeColor)
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 * index))
              .slideX(begin: -0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildPlayerRankCard(Player player, int rank, Color modeColor) {
    final isTopThree = rank <= 3;
    final medals = ['🏆', '🥈', '🥉'];
    final medalColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.space3),
      decoration: BoxDecoration(
        color: ModernDesignSystem.surfaceColor,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
        border:
            isTopThree
                ? Border.all(
                  color: medalColors[rank - 1].withOpacity(0.3),
                  width: 2,
                )
                : null,
        boxShadow:
            isTopThree
                ? ModernDesignSystem.elevationColored(medalColors[rank - 1])
                : ModernDesignSystem.elevationLight,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(ModernDesignSystem.space5),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color:
                        isTopThree
                            ? medalColors[rank - 1].withOpacity(0.1)
                            : ModernDesignSystem.neutral100,
                    borderRadius: BorderRadius.circular(
                      ModernDesignSystem.radiusMd,
                    ),
                  ),
                  child: Center(
                    child:
                        isTopThree
                            ? Text(
                              medals[rank - 1],
                              style: ModernDesignSystem.headlineMedium,
                            )
                            : Text(
                              '#$rank',
                              style: ModernDesignSystem.titleLarge.copyWith(
                                color: ModernDesignSystem.neutral600,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                  ),
                ),

                const SizedBox(width: ModernDesignSystem.space4),

                // Player info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: ModernDesignSystem.titleLarge.copyWith(
                          color: ModernDesignSystem.neutral900,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: ModernDesignSystem.space1),
                      Row(
                        children: [
                          _buildStat(
                            icon: AppIcons.truth,
                            value: player.truthsCompleted,
                            color: const Color(0xFF4E9FF7),
                          ),
                          const SizedBox(width: ModernDesignSystem.space4),
                          _buildStat(
                            icon: AppIcons.dare,
                            value: player.daresCompleted,
                            color: ModernDesignSystem.secondaryColor,
                          ),
                          const SizedBox(width: ModernDesignSystem.space4),
                          _buildStat(
                            icon: AppIcons.next,
                            value: player.skips,
                            color: ModernDesignSystem.neutral500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ModernDesignSystem.space4,
                    vertical: ModernDesignSystem.space2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [modeColor, modeColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(
                      ModernDesignSystem.radiusFull,
                    ),
                  ),
                  child: Text(
                    '${player.score}',
                    style: ModernDesignSystem.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required int value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: ModernDesignSystem.iconSizeXs, color: color),
        const SizedBox(width: ModernDesignSystem.space1),
        Text(
          '$value',
          style: ModernDesignSystem.labelMedium.copyWith(
            color: ModernDesignSystem.neutral700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(
    gameState,
    int totalChallenges,
    int totalSkips,
    Color modeColor,
  ) {
    final totalTruths = gameState.players.fold<int>(
      0,
      (int sum, Player player) => sum + player.truthsCompleted,
    );
    final totalDares = gameState.players.fold<int>(
      0,
      (int sum, Player player) => sum + player.daresCompleted,
    );
    final rounds = (totalChallenges + totalSkips) ~/ gameState.players.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Game Statistics',
          style: ModernDesignSystem.headlineSmall.copyWith(
            color: ModernDesignSystem.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(delay: ModernDesignSystem.durationNormal),

        const SizedBox(height: ModernDesignSystem.space5),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: AppIcons.timer,
                label: 'Rounds',
                value: rounds.toString(),
                color: modeColor,
              ),
            ),
            const SizedBox(width: ModernDesignSystem.space4),
            Expanded(
              child: _buildStatCard(
                icon: AppIcons.challenge,
                label: 'Challenges',
                value: totalChallenges.toString(),
                color: ModernDesignSystem.colorSuccess,
              ),
            ),
          ],
        ),

        const SizedBox(height: ModernDesignSystem.space4),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: AppIcons.truth,
                label: 'Truths',
                value: totalTruths.toString(),
                color: const Color(0xFF4E9FF7),
              ),
            ),
            const SizedBox(width: ModernDesignSystem.space4),
            Expanded(
              child: _buildStatCard(
                icon: AppIcons.dare,
                label: 'Dares',
                value: totalDares.toString(),
                color: ModernDesignSystem.secondaryColor,
              ),
            ),
            const SizedBox(width: ModernDesignSystem.space4),
            Expanded(
              child: _buildStatCard(
                icon: AppIcons.next,
                label: 'Skips',
                value: totalSkips.toString(),
                color: ModernDesignSystem.neutral500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
          padding: const EdgeInsets.all(ModernDesignSystem.space5),
          decoration: BoxDecoration(
            color: ModernDesignSystem.surfaceColor,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
            boxShadow: ModernDesignSystem.elevationLight,
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
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
              const SizedBox(height: ModernDesignSystem.space3),
              Text(
                value,
                style: ModernDesignSystem.headlineSmall.copyWith(
                  color: ModernDesignSystem.neutral900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: ModernDesignSystem.space1),
              Text(
                label,
                style: ModernDesignSystem.labelMedium.copyWith(
                  color: ModernDesignSystem.neutral600,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: ModernDesignSystem.durationSmooth)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildActionButton(BuildContext context, bool isGameActive) {
    return Center(
          child: ModernButton(
            label: isGameActive ? 'Continue Game' : 'Back to Home',
            icon: isGameActive ? AppIcons.play : AppIcons.home,
            onPressed: () {
              HapticFeedback.lightImpact();
              AppNavigation.pop(context);
            },
            size: ButtonSize.large,
            width: double.infinity,
          ),
        )
        .animate()
        .fadeIn(delay: ModernDesignSystem.durationSlow)
        .slideY(begin: 0.1, end: 0);
  }
}

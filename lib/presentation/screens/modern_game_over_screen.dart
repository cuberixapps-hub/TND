import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:share_plus/share_plus.dart'; // TODO: Add share_plus to pubspec.yaml
import 'dart:ui';
import 'dart:math' as math;
import '../../core/theme/modern_design_system.dart';
import '../../core/theme/app_icons.dart';
import '../../data/models/player_model.dart';
import '../../core/extensions/enum_extensions.dart';
import '../providers/game_provider.dart';
import '../utils/post_game_upsell.dart';
import 'quirky_home_screen.dart';
import 'modern_player_setup_screen.dart';

class ModernGameOverScreen extends ConsumerStatefulWidget {
  const ModernGameOverScreen({super.key});

  @override
  ConsumerState<ModernGameOverScreen> createState() =>
      _ModernGameOverScreenState();
}

class _ModernGameOverScreenState extends ConsumerState<ModernGameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _contentController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: ModernDesignSystem.durationSlow,
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _celebrationController.forward();
    Future.delayed(ModernDesignSystem.durationNormal, () {
      if (mounted) _contentController.forward();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      schedulePostGamePremiumUpsell(context: context, ref: ref);
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _contentController.dispose();
    _particleController.dispose();
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

    if (gameState == null || leaderboard.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final winner = leaderboard.first;
    final modeColor = _getModeColor(gameState.mode.enumName);
    final totalChallenges = gameState.players.fold<int>(
      0,
      (int sum, Player player) =>
          sum + player.truthsCompleted + player.daresCompleted,
    );

    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundPrimary,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(modeColor),

          // Particles
          _buildParticles(modeColor),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(ModernDesignSystem.space6),
                      child: Column(
                        children: [
                          const SizedBox(height: ModernDesignSystem.space8),

                          // Trophy animation
                          _buildTrophyAnimation(modeColor),

                          const SizedBox(height: ModernDesignSystem.space8),

                          // Winner announcement
                          _buildWinnerAnnouncement(winner, modeColor),

                          const SizedBox(height: ModernDesignSystem.space10),

                          // Podium
                          _buildPodium(leaderboard, modeColor),

                          const SizedBox(height: ModernDesignSystem.space10),

                          // Game stats
                          _buildGameStats(
                            gameState,
                            totalChallenges,
                            modeColor,
                          ),

                          // Extra padding for bottom buttons
                          const SizedBox(height: ModernDesignSystem.space6),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sticky bottom buttons
                Container(
                  decoration: BoxDecoration(
                    color: ModernDesignSystem.backgroundPrimary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    left: ModernDesignSystem.space6,
                    right: ModernDesignSystem.space6,
                    top: ModernDesignSystem.space5,
                    bottom:
                        MediaQuery.of(context).padding.bottom +
                        ModernDesignSystem.space5,
                  ),
                  child: _buildActionButtons(context, gameState),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Color modeColor) {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_celebrationController.value * 2 * math.pi) * 0.3,
                math.cos(_celebrationController.value * 2 * math.pi) * 0.3,
              ),
              radius: 2.0,
              colors: [
                modeColor.withOpacity(0.15),
                modeColor.withOpacity(0.05),
                ModernDesignSystem.backgroundPrimary,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticles(Color modeColor) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: ParticlePainter(
            progress: _particleController.value,
            color: modeColor,
          ),
        );
      },
    );
  }

  Widget _buildTrophyAnimation(Color modeColor) {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        final scale = 0.5 + (_celebrationController.value * 0.5);
        final rotation = _celebrationController.value * 2 * math.pi;

        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation * 0.1,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 80)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWinnerAnnouncement(Player winner, Color modeColor) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Opacity(
          opacity: _contentController.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _contentController.value)),
            child: Column(
              children: [
                Text(
                  'CHAMPION',
                  style: ModernDesignSystem.labelLarge.copyWith(
                    color: modeColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: ModernDesignSystem.space3),
                Text(
                  winner.name,
                  style: ModernDesignSystem.displayMedium.copyWith(
                    color: ModernDesignSystem.neutral900,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: ModernDesignSystem.space4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ModernDesignSystem.space6,
                    vertical: ModernDesignSystem.space3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [modeColor, modeColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(
                      ModernDesignSystem.radiusFull,
                    ),
                    boxShadow: ModernDesignSystem.elevationColored(modeColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.star,
                        color: Colors.white,
                        size: ModernDesignSystem.iconSizeMd,
                      ),
                      const SizedBox(width: ModernDesignSystem.space2),
                      Text(
                        '${winner.score} Points',
                        style: ModernDesignSystem.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPodium(List<Player> leaderboard, Color modeColor) {
    final topThree = leaderboard.take(3).toList();
    if (topThree.length < 2) return const SizedBox.shrink();

    return Container(
      height: 280,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Podium platforms
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (topThree.length >= 2)
                _buildPodiumPlatform(topThree[1], 2, 180, modeColor),
              _buildPodiumPlatform(topThree[0], 1, 220, modeColor),
              if (topThree.length >= 3)
                _buildPodiumPlatform(topThree[2], 3, 140, modeColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlatform(
    Player player,
    int position,
    double height,
    Color modeColor,
  ) {
    final medals = ['🥇', '🥈', '🥉'];
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];

    return Container(
          width: 110,
          margin: const EdgeInsets.symmetric(
            horizontal: ModernDesignSystem.space2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Player info
              Container(
                padding: const EdgeInsets.all(ModernDesignSystem.space3),
                decoration: BoxDecoration(
                  color: ModernDesignSystem.surfaceColor,
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusMd,
                  ),
                  boxShadow: ModernDesignSystem.elevationLight,
                ),
                child: Column(
                  children: [
                    Text(
                      medals[position - 1],
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: ModernDesignSystem.space2),
                    Text(
                      player.name,
                      style: ModernDesignSystem.labelLarge.copyWith(
                        color: ModernDesignSystem.neutral900,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: ModernDesignSystem.space1),
                    Text(
                      '${player.score} pts',
                      style: ModernDesignSystem.labelMedium.copyWith(
                        color: colors[position - 1],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: ModernDesignSystem.space3),

              // Platform
              AnimatedContainer(
                duration: ModernDesignSystem.durationSmooth,
                height: height,
                width: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors[position - 1],
                      colors[position - 1].withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(ModernDesignSystem.radiusMd),
                    topRight: Radius.circular(ModernDesignSystem.radiusMd),
                  ),
                  boxShadow: ModernDesignSystem.elevationColored(
                    colors[position - 1],
                  ),
                ),
                child: Center(
                  child: Text(
                    '$position',
                    style: ModernDesignSystem.displaySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 200 * position))
        .slideY(begin: 1, end: 0)
        .fadeIn();
  }

  Widget _buildGameStats(gameState, int totalChallenges, Color modeColor) {
    final duration = DateTime.now().difference(gameState.startedAt);
    final minutes = duration.inMinutes;
    final rounds = totalChallenges ~/ gameState.players.length;

    return Container(
          padding: const EdgeInsets.all(ModernDesignSystem.space6),
          decoration: BoxDecoration(
            color: ModernDesignSystem.surfaceColor,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radius2xl),
            boxShadow: ModernDesignSystem.elevationMedium,
          ),
          child: Column(
            children: [
              Text(
                'Game Summary',
                style: ModernDesignSystem.headlineSmall.copyWith(
                  color: ModernDesignSystem.neutral900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: ModernDesignSystem.space6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    icon: AppIcons.timer,
                    value: '${minutes}m',
                    label: 'Duration',
                    color: modeColor,
                  ),
                  _buildStatItem(
                    icon: AppIcons.challenge,
                    value: '$rounds',
                    label: 'Rounds',
                    color: ModernDesignSystem.colorSuccess,
                  ),
                  _buildStatItem(
                    icon: AppIcons.team,
                    value: '${gameState.players.length}',
                    label: 'Players',
                    color: ModernDesignSystem.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: ModernDesignSystem.durationSlow)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
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
        const SizedBox(height: ModernDesignSystem.space3),
        Text(
          value,
          style: ModernDesignSystem.titleLarge.copyWith(
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
    );
  }

  Widget _buildActionButtons(BuildContext context, gameState) {
    final modeColor = _getModeColor(gameState.mode.enumName);

    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play Again - Primary button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [modeColor.withOpacity(0.9), modeColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusFull,
                ),
                boxShadow: [
                  BoxShadow(
                    color: modeColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _playAgain(context, gameState),
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusFull,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: ModernDesignSystem.space2),
                        Text(
                          'Play Again',
                          style: ModernDesignSystem.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: ModernDesignSystem.space4),

            // Share and Home buttons
            Row(
              children: [
                // Share button
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: ModernDesignSystem.surfaceColor,
                      borderRadius: BorderRadius.circular(
                        ModernDesignSystem.radiusFull,
                      ),
                      border: Border.all(
                        color: ModernDesignSystem.neutral200,
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _shareResults(gameState),
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radiusFull,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.share_outlined,
                                color: ModernDesignSystem.neutral700,
                                size: 20,
                              ),
                              const SizedBox(width: ModernDesignSystem.space2),
                              Text(
                                'Share',
                                style: ModernDesignSystem.bodyLarge.copyWith(
                                  color: ModernDesignSystem.neutral700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: ModernDesignSystem.space3),

                // Home button
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: ModernDesignSystem.surfaceColor,
                      borderRadius: BorderRadius.circular(
                        ModernDesignSystem.radiusFull,
                      ),
                      border: Border.all(
                        color: ModernDesignSystem.neutral200,
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _goHome(context),
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radiusFull,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.home_outlined,
                                color: ModernDesignSystem.neutral700,
                                size: 20,
                              ),
                              const SizedBox(width: ModernDesignSystem.space2),
                              Text(
                                'Home',
                                style: ModernDesignSystem.bodyLarge.copyWith(
                                  color: ModernDesignSystem.neutral700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
        .animate()
        .fadeIn(delay: ModernDesignSystem.durationGentle)
        .slideY(begin: 0.1, end: 0);
  }

  void _shareResults(gameState) {
    // TODO: Uncomment when share_plus is added
    // final leaderboard = ref.read(leaderboardProvider);
    // final winner = leaderboard.first;
    // final message = '''
    // 🏆 Truth or Dare Results!
    //
    // Champion: ${winner.name} (${winner.score} points)
    // Game Mode: ${gameState.mode.label}
    // Total Players: ${gameState.players.length}
    //
    // Thanks for playing! 🎉
    // ''';
    // Share.share(message);

    HapticFeedback.mediumImpact();
  }

  void _playAgain(BuildContext context, gameState) {
    HapticFeedback.mediumImpact();
    ref.read(gameProvider.notifier).resetGame();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => ModernPlayerSetupScreen(mode: gameState.mode),
      ),
      (route) => route.isFirst,
    );
  }

  void _goHome(BuildContext context) {
    HapticFeedback.lightImpact();
    ref.read(gameProvider.notifier).resetGame();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const QuirkyHomeScreen()),
      (route) => false,
    );
  }
}

// Custom painter for particles
class ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final y = (startY - (progress * size.height * 1.5)) % size.height;
      final radius = random.nextDouble() * 3 + 1;

      paint.color = color.withOpacity(0.1 + random.nextDouble() * 0.2);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

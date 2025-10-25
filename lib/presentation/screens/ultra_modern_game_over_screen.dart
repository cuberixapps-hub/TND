import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:share_plus/share_plus.dart'; // TODO: Add share_plus to pubspec.yaml
import 'dart:ui';
import 'dart:math' as math;
import '../../core/theme/modern_design_system.dart';
import '../../data/models/player_model.dart';
import '../../core/extensions/enum_extensions.dart';
import '../providers/game_provider.dart';
import 'quirky_home_screen.dart';
import 'modern_player_setup_screen.dart';

class UltraModernGameOverScreen extends ConsumerStatefulWidget {
  const UltraModernGameOverScreen({super.key});

  @override
  ConsumerState<UltraModernGameOverScreen> createState() =>
      _UltraModernGameOverScreenState();
}

class _UltraModernGameOverScreenState
    extends ConsumerState<UltraModernGameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _scaleController.forward();
        _confettiController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _confettiController.dispose();
    _scrollController.dispose();
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
          // Subtle animated background
          _buildSubtleBackground(modeColor),

          // Confetti animation (subtle)
          if (_confettiController.isAnimating) _buildConfetti(modeColor),

          // Main content
          SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.fast,
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ModernDesignSystem.space5,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: ModernDesignSystem.space6),

                        // Modern winner announcement
                        _buildModernWinnerCard(winner, modeColor),

                        const SizedBox(height: ModernDesignSystem.space8),

                        // Clean leaderboard
                        _buildModernLeaderboard(leaderboard, modeColor),

                        const SizedBox(height: ModernDesignSystem.space8),

                        // Minimal game stats
                        _buildMinimalStats(
                          gameState,
                          totalChallenges,
                          modeColor,
                        ),

                        const SizedBox(height: ModernDesignSystem.space8),

                        // Modern action buttons
                        _buildModernActions(context, gameState, modeColor),

                        const SizedBox(height: ModernDesignSystem.space6),
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

  Widget _buildSubtleBackground(Color modeColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            modeColor.withOpacity(0.03),
            ModernDesignSystem.backgroundPrimary,
            ModernDesignSystem.backgroundPrimary,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
    );
  }

  Widget _buildConfetti(Color modeColor) {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: ConfettiPainter(
            progress: _confettiController.value,
            color: modeColor,
          ),
        );
      },
    );
  }

  Widget _buildModernWinnerCard(Player winner, Color modeColor) {
    return FadeTransition(
      opacity: _fadeController,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _scaleController,
          curve: Curves.easeOutBack,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(ModernDesignSystem.space6),
          decoration: BoxDecoration(
            color: ModernDesignSystem.surfaceColor,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radius3xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: modeColor.withOpacity(0.08),
                blurRadius: 40,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Crown icon
              Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFD700),
                          const Color(0xFFFFA500),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  )
                  .animate(delay: 300.ms)
                  .scale(duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: ModernDesignSystem.space5),

              // Winner text
              Text(
                'WINNER',
                style: ModernDesignSystem.labelMedium.copyWith(
                  color: modeColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: ModernDesignSystem.space2),

              // Winner name
              Text(
                winner.name,
                style: ModernDesignSystem.headlineMedium.copyWith(
                  color: ModernDesignSystem.neutral900,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: ModernDesignSystem.space4),

              // Score pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ModernDesignSystem.space5,
                  vertical: ModernDesignSystem.space3,
                ),
                decoration: BoxDecoration(
                  color: modeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusFull,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: modeColor, size: 20),
                    const SizedBox(width: ModernDesignSystem.space2),
                    Text(
                      '${winner.score} points',
                      style: ModernDesignSystem.titleMedium.copyWith(
                        color: modeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernLeaderboard(List<Player> leaderboard, Color modeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leaderboard',
          style: ModernDesignSystem.titleLarge.copyWith(
            color: ModernDesignSystem.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: ModernDesignSystem.space4),
        ...leaderboard.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          return _buildLeaderboardItem(player, index + 1, modeColor)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 600 + (index * 100)),
                duration: const Duration(milliseconds: 400),
              )
              .slideX(
                begin: 0.1,
                end: 0,
                delay: Duration(milliseconds: 600 + (index * 100)),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuart,
              );
        }),
      ],
    );
  }

  Widget _buildLeaderboardItem(Player player, int position, Color modeColor) {
    final isWinner = position == 1;
    final medalColors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.space3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => HapticFeedback.lightImpact(),
          borderRadius: BorderRadius.circular(ModernDesignSystem.radius2xl),
          child: Container(
            padding: const EdgeInsets.all(ModernDesignSystem.space4),
            decoration: BoxDecoration(
              color:
                  isWinner
                      ? modeColor.withOpacity(0.05)
                      : ModernDesignSystem.surfaceColor,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radius2xl),
              border: Border.all(
                color:
                    isWinner
                        ? modeColor.withOpacity(0.2)
                        : ModernDesignSystem.neutral200,
                width: isWinner ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Position badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        position <= 3
                            ? medalColors[position]!.withOpacity(0.15)
                            : ModernDesignSystem.neutral100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        position <= 3
                            ? Icon(
                              Icons.workspace_premium_rounded,
                              color: medalColors[position],
                              size: 24,
                            )
                            : Text(
                              '$position',
                              style: ModernDesignSystem.titleMedium.copyWith(
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
                        style: ModernDesignSystem.titleMedium.copyWith(
                          color: ModernDesignSystem.neutral900,
                          fontWeight:
                              isWinner ? FontWeight.w700 : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: ModernDesignSystem.space1),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: ModernDesignSystem.neutral500,
                          ),
                          const SizedBox(width: ModernDesignSystem.space1),
                          Text(
                            '${player.truthsCompleted + player.daresCompleted} completed',
                            style: ModernDesignSystem.bodySmall.copyWith(
                              color: ModernDesignSystem.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${player.score}',
                      style: ModernDesignSystem.headlineSmall.copyWith(
                        color:
                            isWinner
                                ? modeColor
                                : ModernDesignSystem.neutral900,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'points',
                      style: ModernDesignSystem.bodySmall.copyWith(
                        color: ModernDesignSystem.neutral500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalStats(gameState, int totalChallenges, Color modeColor) {
    final duration = DateTime.now().difference(gameState.startedAt);
    final minutes = duration.inMinutes;
    final rounds = totalChallenges ~/ gameState.players.length;

    return Container(
          padding: const EdgeInsets.all(ModernDesignSystem.space5),
          decoration: BoxDecoration(
            color: ModernDesignSystem.surfaceColor,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radius2xl),
            border: Border.all(color: ModernDesignSystem.neutral200, width: 1),
          ),
          child: Column(
            children: [
              Text(
                'Game Summary',
                style: ModernDesignSystem.titleMedium.copyWith(
                  color: ModernDesignSystem.neutral900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: ModernDesignSystem.space5),
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.timer_outlined,
                    value: '${minutes}m',
                    label: 'Duration',
                    color: const Color(0xFFFF6B6B),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: ModernDesignSystem.neutral200,
                  ),
                  _buildStatItem(
                    icon: Icons.refresh_rounded,
                    value: '$rounds',
                    label: 'Rounds',
                    color: const Color(0xFF4ECDC4),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: ModernDesignSystem.neutral200,
                  ),
                  _buildStatItem(
                    icon: Icons.people_outline_rounded,
                    value: '${gameState.players.length}',
                    label: 'Players',
                    color: const Color(0xFF6366F1),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 600.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          delay: 1000.ms,
          duration: 600.ms,
          curve: Curves.easeOutQuart,
        );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(icon, color: color, size: 24)),
          ),
          const SizedBox(height: ModernDesignSystem.space3),
          Text(
            value,
            style: ModernDesignSystem.headlineSmall.copyWith(
              color: ModernDesignSystem.neutral900,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: ModernDesignSystem.bodySmall.copyWith(
              color: ModernDesignSystem.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActions(BuildContext context, gameState, Color modeColor) {
    return Column(
      children: [
        // Play Again button - primary
        Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [modeColor, modeColor.withOpacity(0.9)],
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
                        const Icon(
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .animate(delay: 1200.ms)
            .fadeIn(duration: 400.ms)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: ModernDesignSystem.space4),

        // Secondary actions
        Row(
          children: [
            // Share button
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ModernDesignSystem.neutral300,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusFull,
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
                  color: ModernDesignSystem.neutral100,
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusFull,
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
        ).animate(delay: 1400.ms).fadeIn(duration: 400.ms),
      ],
    );
  }

  void _shareResults(gameState) {
    // TODO: Implement share functionality when share_plus is added
    // final leaderboard = ref.read(leaderboardProvider);
    // final winner = leaderboard.first;
    // final message = '''🏆 Truth or Dare Champion: ${winner.name}!
    //
    // 📊 Final Score: ${winner.score} points
    // 🎮 Game Mode: ${gameState.mode.label}
    // 👥 Players: ${gameState.players.length}
    //
    // Thanks for playing! 🎉''';
    // Share.share(message);

    HapticFeedback.mediumImpact();

    // Show a snackbar for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
        ),
      ),
    );
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

// Confetti painter for subtle celebration effect
class ConfettiPainter extends CustomPainter {
  final double progress;
  final Color color;

  ConfettiPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress > 0.8) return; // Fade out confetti

    final paint = Paint()..style = PaintingStyle.fill;

    final random = math.Random(42);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final startY = -20.0;
      final y = startY + (progress * size.height * 1.2);

      if (y > size.height) continue;

      final rotation = random.nextDouble() * 2 * math.pi * progress;
      final scale = 0.5 + random.nextDouble() * 0.5;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.scale(scale);

      // Draw confetti shape
      final rect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, -3, 12, 6),
        const Radius.circular(2),
      );

      paint.color = color.withOpacity(opacity * 0.6);
      canvas.drawRRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

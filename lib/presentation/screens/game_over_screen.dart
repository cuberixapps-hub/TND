import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../data/models/player_model.dart';
import '../../data/models/game_state_model.dart';
import '../providers/game_provider.dart';
import '../providers/players_provider.dart';
import 'modern_home_screen.dart';
import 'game_play_screen.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  const GameOverScreen({super.key});

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _confettiController;
  late Animation<double> _celebrationAnimation;
  final List<ConfettiPiece> _confettiPieces = [];

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _celebrationAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    );

    // Initialize confetti
    _initConfetti();

    // Start animations
    _celebrationController.forward();
    _confettiController.forward();
  }

  void _initConfetti() {
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _confettiPieces.add(
        ConfettiPiece(
          color:
              [
                const Color(0xFFFBBF24),
                const Color(0xFFF59E0B),
                const Color(0xFF3B82F6),
                const Color(0xFFEC4899),
                const Color(0xFF10B981),
                const Color(0xFF8B5CF6),
              ][random.nextInt(6)],
          x: random.nextDouble(),
          delay: random.nextDouble() * 0.5,
          rotationSpeed: random.nextDouble() * 2 + 1,
          size: random.nextDouble() * 10 + 5,
        ),
      );
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Color _getModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'kids':
        return const Color(0xFF10B981);
      case 'teens':
        return const Color(0xFF3B82F6);
      case 'adult':
        return const Color(0xFFEF4444);
      case 'couples':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final leaderboard = ref.watch(leaderboardProvider);

    if (gameState == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final winner = gameState.winner;
    final modeColor = _getModeColor(gameState.mode.name);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Confetti animation
          ..._confettiPieces.map((piece) => _buildConfettiPiece(piece)),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),

                        // Winner announcement
                        if (winner != null)
                          _buildWinnerAnnouncement(winner, modeColor),

                        const SizedBox(height: 40),

                        // Rankings
                        _buildRankings(leaderboard, modeColor),

                        const SizedBox(height: 32),

                        // Game statistics
                        _buildGameStatistics(gameState, modeColor),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Bottom actions
                _buildBottomActions(context, ref, gameState, modeColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiPiece(ConfettiPiece piece) {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        final progress = _confettiController.value;
        final delayedProgress = math.max(0, progress - piece.delay);

        if (delayedProgress == 0) return const SizedBox.shrink();

        final screenHeight = MediaQuery.of(context).size.height;
        final y = delayedProgress * screenHeight * 1.2;
        final x =
            piece.x * MediaQuery.of(context).size.width +
            math.sin(delayedProgress * math.pi * 4) * 30.0;
        final rotation = delayedProgress * piece.rotationSpeed * math.pi * 2;
        final opacity = math.max(0.0, 1.0 - delayedProgress);

        return Positioned(
          left: x,
          top: y - 100,
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: piece.size,
                height: piece.size * 0.6,
                decoration: BoxDecoration(
                  color: piece.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            'Game Over',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          // Share button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _showShareDialog(context);
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
                  Icons.share_rounded,
                  color: Color(0xFF374151),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerAnnouncement(Player winner, Color modeColor) {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_celebrationAnimation.value * 0.2),
          child: Opacity(
            opacity: _celebrationAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Trophy icon with pulse animation
                  Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🏆', style: TextStyle(fontSize: 48)),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.1, 1.1),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                      ),

                  const SizedBox(height: 20),

                  Text(
                    'WINNER',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    winner.name,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWinnerStat(
                        Icons.star_rounded,
                        '${winner.score}',
                        'Points',
                      ),
                      const SizedBox(width: 24),
                      _buildWinnerStat(
                        Icons.emoji_events_rounded,
                        '${winner.truthsCompleted + winner.daresCompleted}',
                        'Completed',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWinnerStat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankings(List<Player> leaderboard, Color modeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Final Rankings',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        ...leaderboard.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          final rank = index + 1;

          return _buildRankingCard(player, rank, modeColor)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 600 + (index * 100)),
                duration: const Duration(milliseconds: 400),
              )
              .slideX(
                begin: 0.1,
                end: 0,
                delay: Duration(milliseconds: 600 + (index * 100)),
              );
        }).toList(),
      ],
    );
  }

  Widget _buildRankingCard(Player player, int rank, Color modeColor) {
    final isTopThree = rank <= 3;
    final medals = ['🥇', '🥈', '🥉'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            isTopThree
                ? Border.all(
                  color: [
                    const Color(0xFFFBBF24),
                    const Color(0xFF9CA3AF),
                    const Color(0xFFF97316),
                  ][rank - 1].withOpacity(0.3),
                  width: 1.5,
                )
                : null,
        boxShadow: [
          BoxShadow(
            color:
                isTopThree
                    ? [
                      const Color(0xFFFBBF24),
                      const Color(0xFF9CA3AF),
                      const Color(0xFFF97316),
                    ][rank - 1].withOpacity(0.1)
                    : Colors.black.withOpacity(0.04),
            blurRadius: isTopThree ? 20 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child:
                  isTopThree
                      ? Text(
                        medals[rank - 1],
                        style: const TextStyle(fontSize: 24),
                      )
                      : Text(
                        '#$rank',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
            ),
          ),

          const SizedBox(width: 16),

          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${player.truthsCompleted} truths • ${player.daresCompleted} dares',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: modeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${player.score} pts',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: modeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatistics(GameState gameState, Color modeColor) {
    final totalChallenges = gameState.players.fold<int>(
      0,
      (int sum, Player player) =>
          sum + player.truthsCompleted + player.daresCompleted,
    );
    final totalSkips = gameState.players.fold<int>(
      0,
      (int sum, Player player) => sum + player.skips,
    );
    final totalTruths = gameState.players.fold<int>(
      0,
      (int sum, Player player) => sum + player.truthsCompleted,
    );
    final totalDares = gameState.players.fold<int>(
      0,
      (int sum, Player player) => sum + player.daresCompleted,
    );

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game Statistics',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Rounds',
                    ((totalChallenges + totalSkips) ~/ gameState.players.length)
                        .toString(),
                    Icons.loop_rounded,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Challenges',
                    totalChallenges.toString(),
                    Icons.check_circle_outline_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Truths',
                    totalTruths.toString(),
                    Icons.psychology_outlined,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Dares',
                    totalDares.toString(),
                    Icons.flash_on_outlined,
                    const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Skips',
                    totalSkips.toString(),
                    Icons.skip_next_rounded,
                    const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 1000),
          duration: const Duration(milliseconds: 400),
        )
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    GameState gameState,
    Color modeColor,
  ) {
    return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Home button
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(gameProvider.notifier).resetGame();
                        ref.read(playersProvider.notifier).clearPlayers();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ModernHomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.home_rounded,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Home',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Play Again button
                Expanded(
                  flex: 2,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        final players = List<Player>.from(gameState.players);
                        for (var player in players) {
                          player.reset();
                        }
                        ref
                            .read(gameProvider.notifier)
                            .startNewGame(gameState.mode, players);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GamePlayScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: modeColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: modeColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Play Again',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 1200),
          duration: const Duration(milliseconds: 400),
        )
        .slideY(begin: 0.2, end: 0);
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      color: Color(0xFF3B82F6),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Share Results',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your game results\nwith friends!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement share functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Share',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class ConfettiPiece {
  final Color color;
  final double x;
  final double delay;
  final double rotationSpeed;
  final double size;

  ConfettiPiece({
    required this.color,
    required this.x,
    required this.delay,
    required this.rotationSpeed,
    required this.size,
  });
}

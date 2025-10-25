import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../providers/players_provider.dart';
import 'home_screen.dart';

class ScoreboardScreen extends ConsumerWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final leaderboard = ref.watch(leaderboardProvider);

    if (gameState == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFBFD),
        body: Center(
          child: Text(
            'No game data available',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
          ),
        ),
      );
    }

    // Define modern mode colors
    final modeColors = {
      'classic': const Color(0xFF6366F1),
      'couples': const Color(0xFFEC4899),
      'party': const Color(0xFFF59E0B),
      'kids': const Color(0xFF10B981),
      'extreme': const Color(0xFFEF4444),
    };

    final modeColor =
        modeColors[gameState.mode.name.toLowerCase()] ??
        const Color(0xFF6366F1);
    final winner = gameState.winner;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildModernHeader(context, ref),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Winner Section (if game ended)
                    if (winner != null) ...[
                      _buildModernWinnerSection(context, winner, modeColor),
                      const SizedBox(height: 32),
                    ],

                    // Leaderboard
                    _buildModernLeaderboard(context, leaderboard, modeColor),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            _buildModernBottomActions(
              context,
              ref,
              modeColor,
              !gameState.isActive,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 44), // Balance the layout
          Text(
            'Scoreboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
          // Close button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                if (!(ref.read(gameProvider)?.isActive ?? true)) {
                  ref.read(gameProvider.notifier).resetGame();
                  ref.read(playersProvider.notifier).clearPlayers();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF374151),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildModernWinnerSection(
    BuildContext context,
    winner,
    Color modeColor,
  ) {
    return Container(
          padding: const EdgeInsets.all(24),
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
                offset: const Offset(0, 15),
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
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text('👑', style: TextStyle(fontSize: 48)),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                  ),

              const SizedBox(height: 16),

              Text(
                'WINNER',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                    winner.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 600),
                  )
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${winner.score} points',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(
          begin: 0.1,
          end: 0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        );
  }

  Widget _buildModernLeaderboard(
    BuildContext context,
    leaderboard,
    Color modeColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leaderboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        ...leaderboard.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          return _buildModernPlayerRow(context, player, index + 1, modeColor);
        }).toList(),
      ],
    );
  }

  Widget _buildModernPlayerRow(
    BuildContext context,
    player,
    int rank,
    Color modeColor,
  ) {
    // Define colors for top 3
    Color? rankColor;
    IconData? rankIcon;
    if (rank == 1) {
      rankColor = const Color(0xFFFBBF24);
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 2) {
      rankColor = const Color(0xFF9CA3AF);
      rankIcon = Icons.workspace_premium_rounded;
    } else if (rank == 3) {
      rankColor = const Color(0xFFF97316);
      rankIcon = Icons.military_tech_rounded;
    }

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  rank <= 3
                      ? rankColor!.withOpacity(0.3)
                      : const Color(0xFFE5E7EB),
              width: rank <= 3 ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    rank <= 3
                        ? rankColor!.withOpacity(0.1)
                        : Colors.black.withOpacity(0.04),
                blurRadius: rank <= 3 ? 20 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rank indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      rank <= 3
                          ? rankColor!.withOpacity(0.1)
                          : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child:
                      rank <= 3
                          ? Icon(rankIcon, color: rankColor, size: 24)
                          : Text(
                            '#$rank',
                            style: TextStyle(
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.check_circle_outline,
                          '${player.truthsCompleted + player.daresCompleted}',
                          const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          Icons.cancel_outlined,
                          '${player.challengesSkipped}',
                          const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Score
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: modeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${player.score}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: modeColor,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 + (rank * 50)),
          duration: const Duration(milliseconds: 400),
        )
        .slideX(
          begin: -0.05,
          end: 0,
          delay: Duration(milliseconds: 100 + (rank * 50)),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildModernBottomActions(
    BuildContext context,
    WidgetRef ref,
    Color modeColor,
    bool isGameOver,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child:
          isGameOver
              ? Row(
                children: [
                  // New Game button
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
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.home_outlined,
                                color: Color(0xFF6B7280),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Home',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
                          ref
                              .read(gameProvider.notifier)
                              .startNewGame(
                                ref.read(gameProvider)!.mode,
                                ref.read(gameProvider)!.players,
                              );
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        splashColor: modeColor.withOpacity(0.1),
                        highlightColor: modeColor.withOpacity(0.05),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: modeColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: modeColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
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
                              const SizedBox(width: 8),
                              const Text(
                                'Play Again',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  splashColor: modeColor.withOpacity(0.1),
                  highlightColor: modeColor.withOpacity(0.05),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: modeColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: modeColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Back to Game',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

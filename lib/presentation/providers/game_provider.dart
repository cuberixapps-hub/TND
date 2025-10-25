import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/player_model.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/game_state_model.dart';
import '../../data/datasources/preloaded_challenges.dart';
import 'custom_challenges_provider.dart';
import 'stats_provider.dart';

class GameNotifier extends StateNotifier<GameState?> {
  final Ref ref;

  GameNotifier(this.ref) : super(null);

  final Random _random = Random();

  void startNewGame(GameMode mode, List<Player> players) {
    if (players.length < AppConstants.minPlayers) {
      throw Exception('Minimum ${AppConstants.minPlayers} players required');
    }

    if (players.length > AppConstants.maxPlayers) {
      throw Exception('Maximum ${AppConstants.maxPlayers} players allowed');
    }

    // Reset all player scores
    for (var player in players) {
      player.reset();
    }

    state = GameState(
      mode: mode,
      players: players,
      currentPlayerIndex: 0,
      isActive: true,
    );
  }

  Challenge? getRandomChallenge(ChallengeType type) {
    if (state == null) return null;

    // Get both preloaded and custom challenges
    final preloadedChallenges = PreloadedChallenges.getChallengesForMode(
      state!.mode,
    );
    final customChallenges =
        ref
            .read(customChallengesProvider)
            .where((c) => c.mode == state!.mode)
            .toList();

    final allChallenges = [...preloadedChallenges, ...customChallenges];
    final availableChallenges =
        allChallenges
            .where((c) => c.type == type)
            .where((c) => !state!.usedChallenges.contains(c))
            .toList();

    if (availableChallenges.isEmpty) {
      // Reset used challenges if all have been used
      state = GameState(
        id: state!.id,
        mode: state!.mode,
        players: state!.players,
        usedChallenges: [],
        currentPlayerIndex: state!.currentPlayerIndex,
        startedAt: state!.startedAt,
        isActive: state!.isActive,
      );

      return getRandomChallenge(type);
    }

    final challenge =
        availableChallenges[_random.nextInt(availableChallenges.length)];
    state!.addUsedChallenge(challenge);

    return challenge;
  }

  void completeChallenge(ChallengeType type) {
    if (state == null) return;

    final currentPlayer = state!.currentPlayer;

    if (type == ChallengeType.truth) {
      currentPlayer.completeTruth();
      currentPlayer.updateScore(AppConstants.truthCompletePoints);
    } else {
      currentPlayer.completeDare();
      currentPlayer.updateScore(AppConstants.dareCompletePoints);
    }

    _nextTurn();
  }

  void skipChallenge() {
    if (state == null) return;

    final currentPlayer = state!.currentPlayer;
    currentPlayer.skip();
    currentPlayer.updateScore(AppConstants.skipPenaltyPoints);

    _nextTurn();
  }

  // Methods for bottle mode that don't automatically advance turn
  void completeChallengeBottleMode(ChallengeType type) {
    if (state == null) return;

    final currentPlayer = state!.currentPlayer;

    if (type == ChallengeType.truth) {
      currentPlayer.completeTruth();
      currentPlayer.updateScore(AppConstants.truthCompletePoints);
    } else {
      currentPlayer.completeDare();
      currentPlayer.updateScore(AppConstants.dareCompletePoints);
    }

    // Don't call _nextTurn() - the same player spins again
    // Force state update to reflect score changes
    state = GameState(
      id: state!.id,
      mode: state!.mode,
      players: state!.players,
      usedChallenges: state!.usedChallenges,
      currentPlayerIndex: state!.currentPlayerIndex,
      startedAt: state!.startedAt,
      isActive: state!.isActive,
    );
  }

  void skipChallengeBottleMode() {
    if (state == null) return;

    final currentPlayer = state!.currentPlayer;
    currentPlayer.skip();
    currentPlayer.updateScore(AppConstants.skipPenaltyPoints);

    // Don't call _nextTurn() - the same player spins again
    // Force state update to reflect score changes
    state = GameState(
      id: state!.id,
      mode: state!.mode,
      players: state!.players,
      usedChallenges: state!.usedChallenges,
      currentPlayerIndex: state!.currentPlayerIndex,
      startedAt: state!.startedAt,
      isActive: state!.isActive,
    );
  }

  void _nextTurn() {
    if (state == null) return;

    state!.nextPlayer();
    state = GameState(
      id: state!.id,
      mode: state!.mode,
      players: state!.players,
      usedChallenges: state!.usedChallenges,
      currentPlayerIndex: state!.currentPlayerIndex,
      startedAt: state!.startedAt,
      isActive: state!.isActive,
    );
  }

  void setCurrentPlayer(int playerIndex) {
    if (state == null ||
        playerIndex < 0 ||
        playerIndex >= state!.players.length)
      return;

    state = GameState(
      id: state!.id,
      mode: state!.mode,
      players: state!.players,
      usedChallenges: state!.usedChallenges,
      currentPlayerIndex: playerIndex,
      startedAt: state!.startedAt,
      isActive: state!.isActive,
    );
  }

  void endGame() {
    if (state == null) return;

    // Record stats before ending the game
    ref.read(statsProvider.notifier).recordGameEnd(state!);

    state!.endGame();
    state = GameState(
      id: state!.id,
      mode: state!.mode,
      players: state!.players,
      usedChallenges: state!.usedChallenges,
      currentPlayerIndex: state!.currentPlayerIndex,
      startedAt: state!.startedAt,
      endedAt: state!.endedAt,
      isActive: false,
    );
  }

  void resetGame() {
    state = null;
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState?>((ref) {
  return GameNotifier(ref);
});

final currentPlayerProvider = Provider<Player?>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState?.currentPlayer;
});

final leaderboardProvider = Provider<List<Player>>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState?.leaderboard ?? [];
});

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truth_or_dare/presentation/providers/game_provider.dart';
import 'package:truth_or_dare/presentation/providers/players_provider.dart';
import 'package:truth_or_dare/presentation/providers/custom_challenges_provider.dart';
import 'package:truth_or_dare/data/models/challenge_model.dart';
import 'package:truth_or_dare/core/constants/app_constants.dart';
import '../test_helpers/test_data.dart';

void main() {
  group('Game Flow Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Complete game flow from setup to end', () {
      // 1. Setup players
      final playersNotifier = container.read(playersProvider.notifier);
      playersNotifier.addPlayer('Alice');
      playersNotifier.addPlayer('Bob');
      playersNotifier.addPlayer('Charlie');

      final players = container.read(playersProvider);
      expect(players.length, 3);

      // 2. Start new game
      final gameNotifier = container.read(gameProvider.notifier);
      gameNotifier.startNewGame(GameMode.kids, players);

      var gameState = container.read(gameProvider);
      expect(gameState, isNotNull);
      expect(gameState!.isActive, true);
      expect(gameState.currentPlayerIndex, 0);
      expect(gameState.currentPlayer.name, 'Alice');

      // 3. Play first round - Alice completes a truth
      final truthChallenge = gameNotifier.getRandomChallenge(
        ChallengeType.truth,
      );
      expect(truthChallenge, isNotNull);
      expect(truthChallenge!.type, ChallengeType.truth);

      gameNotifier.completeChallenge(ChallengeType.truth);

      gameState = container.read(gameProvider)!;
      expect(gameState.currentPlayerIndex, 1);
      expect(gameState.currentPlayer.name, 'Bob');
      expect(players[0].truthsCompleted, 1);
      expect(players[0].score, AppConstants.truthCompletePoints);

      // 4. Play second round - Bob completes a dare
      final dareChallenge = gameNotifier.getRandomChallenge(ChallengeType.dare);
      expect(dareChallenge, isNotNull);
      expect(dareChallenge!.type, ChallengeType.dare);

      gameNotifier.completeChallenge(ChallengeType.dare);

      gameState = container.read(gameProvider)!;
      expect(gameState.currentPlayerIndex, 2);
      expect(gameState.currentPlayer.name, 'Charlie');
      expect(players[1].daresCompleted, 1);
      expect(players[1].score, AppConstants.dareCompletePoints);

      // 5. Play third round - Charlie skips
      gameNotifier.skipChallenge();

      gameState = container.read(gameProvider)!;
      expect(gameState.currentPlayerIndex, 0); // Back to Alice
      expect(players[2].skips, 1);
      expect(players[2].score, AppConstants.skipPenaltyPoints);

      // 6. Check leaderboard
      final leaderboard = container.read(leaderboardProvider);
      expect(leaderboard[0].name, 'Bob'); // 15 points
      expect(leaderboard[1].name, 'Alice'); // 10 points
      expect(leaderboard[2].name, 'Charlie'); // -5 points

      // 7. End game
      gameNotifier.endGame();

      gameState = container.read(gameProvider)!;
      expect(gameState.isActive, false);
      expect(gameState.endedAt, isNotNull);
      expect(gameState.winner?.name, 'Bob');

      // 8. Reset game
      gameNotifier.resetGame();
      expect(container.read(gameProvider), isNull);
    });

    test('Game with custom challenges', () {
      // 1. Add custom challenges
      final customChallengesNotifier = container.read(
        customChallengesProvider.notifier,
      );

      final customTruth = Challenge(
        content: 'Custom Truth Question',
        type: ChallengeType.truth,
        mode: GameMode.teens,
        isCustom: true,
      );

      final customDare = Challenge(
        content: 'Custom Dare Challenge',
        type: ChallengeType.dare,
        mode: GameMode.teens,
        isCustom: true,
      );

      customChallengesNotifier.addChallenge(customTruth);
      customChallengesNotifier.addChallenge(customDare);

      // 2. Setup players and start game
      final playersNotifier = container.read(playersProvider.notifier);
      playersNotifier.addPlayer('Player 1');
      playersNotifier.addPlayer('Player 2');

      final gameNotifier = container.read(gameProvider.notifier);
      gameNotifier.startNewGame(
        GameMode.teens,
        container.read(playersProvider),
      );

      // 3. Get challenges (should include custom ones)
      bool foundCustomTruth = false;
      bool foundCustomDare = false;

      // Try multiple times to get custom challenges
      for (int i = 0; i < 50 && (!foundCustomTruth || !foundCustomDare); i++) {
        if (!foundCustomTruth) {
          final truth = gameNotifier.getRandomChallenge(ChallengeType.truth);
          if (truth?.isCustom == true) {
            foundCustomTruth = true;
            expect(truth!.content, 'Custom Truth Question');
          }
        }

        if (!foundCustomDare) {
          final dare = gameNotifier.getRandomChallenge(ChallengeType.dare);
          if (dare?.isCustom == true) {
            foundCustomDare = true;
            expect(dare!.content, 'Custom Dare Challenge');
          }
        }
      }

      // Custom challenges should be available in the pool
      expect(foundCustomTruth || foundCustomDare, true);
    });

    test('Multiple games with same players', () {
      // Setup players
      final playersNotifier = container.read(playersProvider.notifier);
      playersNotifier.addPlayer('Alice');
      playersNotifier.addPlayer('Bob');

      final players = container.read(playersProvider);
      final gameNotifier = container.read(gameProvider.notifier);

      // Game 1 - Kids mode
      gameNotifier.startNewGame(GameMode.kids, players);

      // Play some rounds
      gameNotifier.completeChallenge(ChallengeType.truth);
      gameNotifier.completeChallenge(ChallengeType.dare);

      // Check scores
      expect(players[0].score, AppConstants.truthCompletePoints);
      expect(players[1].score, AppConstants.dareCompletePoints);

      // End first game
      gameNotifier.endGame();

      // Game 2 - Teens mode (scores should reset)
      gameNotifier.startNewGame(GameMode.teens, players);

      var gameState = container.read(gameProvider);
      expect(gameState!.mode, GameMode.teens);
      expect(players[0].score, 0);
      expect(players[1].score, 0);
      expect(players[0].truthsCompleted, 0);
      expect(players[1].daresCompleted, 0);

      // Play new game
      gameNotifier.completeChallenge(ChallengeType.dare);
      expect(players[0].score, AppConstants.dareCompletePoints);
    });

    test('Challenge exhaustion and reset', () {
      final playersNotifier = container.read(playersProvider.notifier);
      playersNotifier.addPlayer('Player 1');
      playersNotifier.addPlayer('Player 2');

      final gameNotifier = container.read(gameProvider.notifier);
      gameNotifier.startNewGame(GameMode.kids, container.read(playersProvider));

      // Use many challenges to trigger reset
      final usedChallenges = <Challenge>{};

      for (int i = 0; i < 100; i++) {
        final challenge = gameNotifier.getRandomChallenge(ChallengeType.truth);
        if (challenge != null) {
          usedChallenges.add(challenge);
        }
      }

      // Should still be able to get challenges after exhaustion
      final challengeAfterMany = gameNotifier.getRandomChallenge(
        ChallengeType.truth,
      );
      expect(challengeAfterMany, isNotNull);
    });

    test('Player management during game', () {
      final playersNotifier = container.read(playersProvider.notifier);

      // Add initial players
      playersNotifier.addPlayer('Alice');
      playersNotifier.addPlayer('Bob');
      playersNotifier.addPlayer('Charlie');

      // Reorder players before game
      playersNotifier.reorderPlayers(2, 0);

      var players = container.read(playersProvider);
      expect(players[0].name, 'Charlie');
      expect(players[1].name, 'Alice');
      expect(players[2].name, 'Bob');

      // Start game with reordered players
      final gameNotifier = container.read(gameProvider.notifier);
      gameNotifier.startNewGame(GameMode.kids, players);

      var gameState = container.read(gameProvider);
      expect(gameState!.currentPlayer.name, 'Charlie');

      // Update player avatar during game
      playersNotifier.updatePlayerAvatar(players[0].id, '🎮');
      expect(players[0].avatarEmoji, '🎮');

      // Try to add player during game (should work but not affect current game)
      playersNotifier.addPlayer('David');
      players = container.read(playersProvider);
      expect(players.length, 4);

      // Current game should still have 3 players
      gameState = container.read(gameProvider)!;
      expect(gameState.players.length, 3);
    });

    test('Score tracking across multiple rounds', () {
      final playersNotifier = container.read(playersProvider.notifier);
      playersNotifier.addPlayer('Alice');
      playersNotifier.addPlayer('Bob');

      final players = container.read(playersProvider);
      final gameNotifier = container.read(gameProvider.notifier);

      gameNotifier.startNewGame(GameMode.kids, players);

      // Round 1: Alice completes truth (+10)
      gameNotifier.completeChallenge(ChallengeType.truth);
      expect(players[0].score, 10);
      expect(players[0].truthsCompleted, 1);

      // Round 2: Bob completes dare (+15)
      gameNotifier.completeChallenge(ChallengeType.dare);
      expect(players[1].score, 15);
      expect(players[1].daresCompleted, 1);

      // Round 3: Alice skips (-5)
      gameNotifier.skipChallenge();
      expect(players[0].score, 5);
      expect(players[0].skips, 1);

      // Round 4: Bob completes truth (+10)
      gameNotifier.completeChallenge(ChallengeType.truth);
      expect(players[1].score, 25);
      expect(players[1].truthsCompleted, 1);

      // Round 5: Alice completes dare (+15)
      gameNotifier.completeChallenge(ChallengeType.dare);
      expect(players[0].score, 20);
      expect(players[0].daresCompleted, 1);

      // Final scores
      final leaderboard = container.read(leaderboardProvider);
      expect(leaderboard[0].score, 25); // Bob
      expect(leaderboard[1].score, 20); // Alice
    });

    test('Game mode specific challenges', () {
      final playersNotifier = container.read(playersProvider.notifier);
      playersNotifier.addPlayer('Player 1');
      playersNotifier.addPlayer('Player 2');

      final players = container.read(playersProvider);
      final gameNotifier = container.read(gameProvider.notifier);

      // Test each game mode
      for (final mode in GameMode.values) {
        gameNotifier.startNewGame(mode, players);

        final truthChallenge = gameNotifier.getRandomChallenge(
          ChallengeType.truth,
        );
        final dareChallenge = gameNotifier.getRandomChallenge(
          ChallengeType.dare,
        );

        expect(truthChallenge, isNotNull);
        expect(truthChallenge!.mode, mode);
        expect(truthChallenge.type, ChallengeType.truth);

        expect(dareChallenge, isNotNull);
        expect(dareChallenge!.mode, mode);
        expect(dareChallenge.type, ChallengeType.dare);

        gameNotifier.resetGame();
      }
    });

    test('Concurrent provider updates', () {
      // Test that all providers work together correctly
      final playersNotifier = container.read(playersProvider.notifier);
      final gameNotifier = container.read(gameProvider.notifier);
      final customChallengesNotifier = container.read(
        customChallengesProvider.notifier,
      );

      // Add players
      playersNotifier.addPlayer('Alice');
      playersNotifier.addPlayer('Bob');

      // Add custom challenge
      customChallengesNotifier.addChallenge(
        TestData.createTestChallenge(
          content: 'Integration Test Challenge',
          mode: GameMode.kids,
          isCustom: true,
        ),
      );

      // Start game
      gameNotifier.startNewGame(GameMode.kids, container.read(playersProvider));

      // Play a round
      gameNotifier.completeChallenge(ChallengeType.truth);

      // Update player name
      final players = container.read(playersProvider);
      playersNotifier.updatePlayerName(players[0].id, 'Alice Updated');

      // Add another custom challenge
      customChallengesNotifier.addChallenge(
        TestData.createTestChallenge(
          content: 'Another Custom',
          type: ChallengeType.dare,
          mode: GameMode.kids,
          isCustom: true,
        ),
      );

      // Continue playing
      gameNotifier.completeChallenge(ChallengeType.dare);

      // Verify everything is still consistent
      final gameState = container.read(gameProvider);
      expect(gameState, isNotNull);
      expect(gameState!.isActive, true);
      expect(container.read(customChallengesProvider).length, 2);
      expect(players[0].name, 'Alice Updated');
    });
  });
}

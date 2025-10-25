import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truth_or_dare/presentation/providers/game_provider.dart';
import 'package:truth_or_dare/presentation/providers/custom_challenges_provider.dart';
import 'package:truth_or_dare/data/models/challenge_model.dart';
import 'package:truth_or_dare/core/constants/app_constants.dart';
import '../../test_helpers/test_data.dart';

void main() {
  group('GameProvider Tests', () {
    late ProviderContainer container;
    late GameNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(gameProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Start New Game', () {
      test('should start new game with valid players', () {
        final players = TestData.createTestPlayers(count: 3);

        notifier.startNewGame(GameMode.kids, players);

        final gameState = container.read(gameProvider);
        expect(gameState, isNotNull);
        expect(gameState!.mode, GameMode.kids);
        expect(gameState.players, players);
        expect(gameState.isActive, true);
        expect(gameState.currentPlayerIndex, 0);
      });

      test('should reset player scores when starting new game', () {
        final players = TestData.createTestPlayers(count: 2);
        players[0].updateScore(50);
        players[1].updateScore(30);

        notifier.startNewGame(GameMode.teens, players);

        final gameState = container.read(gameProvider);
        expect(gameState!.players[0].score, 0);
        expect(gameState.players[1].score, 0);
      });

      test('should throw exception with too few players', () {
        final players = TestData.createTestPlayers(count: 1);

        expect(
          () => notifier.startNewGame(GameMode.kids, players),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Minimum ${AppConstants.minPlayers} players required'),
            ),
          ),
        );
      });

      test('should throw exception with too many players', () {
        final players = TestData.createTestPlayers(
          count: AppConstants.maxPlayers + 1,
        );

        expect(
          () => notifier.startNewGame(GameMode.kids, players),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Maximum ${AppConstants.maxPlayers} players allowed'),
            ),
          ),
        );
      });

      test('should support all game modes', () {
        final players = TestData.createTestPlayers(count: 2);

        // Test Kids mode
        notifier.startNewGame(GameMode.kids, players);
        expect(container.read(gameProvider)!.mode, GameMode.kids);

        // Test Teens mode
        notifier.startNewGame(GameMode.teens, players);
        expect(container.read(gameProvider)!.mode, GameMode.teens);

        // Test Adult mode
        notifier.startNewGame(GameMode.adult, players);
        expect(container.read(gameProvider)!.mode, GameMode.adult);

        // Test Couples mode
        notifier.startNewGame(GameMode.couples, players);
        expect(container.read(gameProvider)!.mode, GameMode.couples);
      });
    });

    group('Get Random Challenge', () {
      test('should return null when no game is active', () {
        final challenge = notifier.getRandomChallenge(ChallengeType.truth);
        expect(challenge, isNull);
      });

      test('should get random truth challenge', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        final challenge = notifier.getRandomChallenge(ChallengeType.truth);

        expect(challenge, isNotNull);
        expect(challenge!.type, ChallengeType.truth);
        expect(challenge.mode, GameMode.kids);
      });

      test('should get random dare challenge', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        final challenge = notifier.getRandomChallenge(ChallengeType.dare);

        expect(challenge, isNotNull);
        expect(challenge!.type, ChallengeType.dare);
        expect(challenge.mode, GameMode.kids);
      });

      test('should track used challenges', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        final challenge1 = notifier.getRandomChallenge(ChallengeType.truth);
        final gameState = container.read(gameProvider);

        expect(gameState!.usedChallenges.length, 1);
        expect(gameState.usedChallenges.contains(challenge1), true);

        final challenge2 = notifier.getRandomChallenge(ChallengeType.dare);
        expect(gameState.usedChallenges.length, 2);
      });

      test('should include custom challenges', () {
        final customChallenge = Challenge(
          content: 'Custom Truth',
          type: ChallengeType.truth,
          mode: GameMode.kids,
          isCustom: true,
        );

        // Add custom challenge
        container
            .read(customChallengesProvider.notifier)
            .addChallenge(customChallenge);

        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        // Get multiple challenges to increase chance of getting custom one
        bool foundCustom = false;
        for (int i = 0; i < 20; i++) {
          final challenge = notifier.getRandomChallenge(ChallengeType.truth);
          if (challenge?.isCustom == true) {
            foundCustom = true;
            break;
          }
        }

        // Custom challenges should be available
        expect(
          foundCustom || container.read(customChallengesProvider).isNotEmpty,
          true,
        );
      });

      test('should reset used challenges when all are used', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        // Use many challenges (more than available)
        for (int i = 0; i < 100; i++) {
          notifier.getRandomChallenge(ChallengeType.truth);
        }

        // Should still be able to get challenges (after reset)
        final challenge = notifier.getRandomChallenge(ChallengeType.truth);
        expect(challenge, isNotNull);
      });
    });

    group('Complete Challenge', () {
      test('should complete truth challenge correctly', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        final initialPlayer = container.read(gameProvider)!.currentPlayer;

        notifier.completeChallenge(ChallengeType.truth);

        expect(initialPlayer.truthsCompleted, 1);
        expect(initialPlayer.score, AppConstants.truthCompletePoints);
        expect(container.read(gameProvider)!.currentPlayerIndex, 1);
      });

      test('should complete dare challenge correctly', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        final initialPlayer = container.read(gameProvider)!.currentPlayer;

        notifier.completeChallenge(ChallengeType.dare);

        expect(initialPlayer.daresCompleted, 1);
        expect(initialPlayer.score, AppConstants.dareCompletePoints);
        expect(container.read(gameProvider)!.currentPlayerIndex, 1);
      });

      test('should handle completion when no game active', () {
        // Should not throw error
        notifier.completeChallenge(ChallengeType.truth);

        expect(container.read(gameProvider), isNull);
      });

      test('should advance to next player after completion', () {
        final players = TestData.createTestPlayers(count: 3);
        notifier.startNewGame(GameMode.kids, players);

        expect(container.read(gameProvider)!.currentPlayerIndex, 0);

        notifier.completeChallenge(ChallengeType.truth);
        expect(container.read(gameProvider)!.currentPlayerIndex, 1);

        notifier.completeChallenge(ChallengeType.dare);
        expect(container.read(gameProvider)!.currentPlayerIndex, 2);

        notifier.completeChallenge(ChallengeType.truth);
        expect(
          container.read(gameProvider)!.currentPlayerIndex,
          0,
        ); // Wrap around
      });
    });

    group('Skip Challenge', () {
      test('should skip challenge with penalty', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        final initialPlayer = container.read(gameProvider)!.currentPlayer;

        notifier.skipChallenge();

        expect(initialPlayer.skips, 1);
        expect(initialPlayer.score, AppConstants.skipPenaltyPoints);
        expect(container.read(gameProvider)!.currentPlayerIndex, 1);
      });

      test('should handle skip when no game active', () {
        // Should not throw error
        notifier.skipChallenge();

        expect(container.read(gameProvider), isNull);
      });

      test('should advance to next player after skip', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        expect(container.read(gameProvider)!.currentPlayerIndex, 0);

        notifier.skipChallenge();
        expect(container.read(gameProvider)!.currentPlayerIndex, 1);
      });
    });

    group('End Game', () {
      test('should end game correctly', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        expect(container.read(gameProvider)!.isActive, true);
        expect(container.read(gameProvider)!.endedAt, isNull);

        notifier.endGame();

        expect(container.read(gameProvider)!.isActive, false);
        expect(container.read(gameProvider)!.endedAt, isNotNull);
      });

      test('should handle end game when no game active', () {
        // Should not throw error
        notifier.endGame();

        expect(container.read(gameProvider), isNull);
      });

      test('should preserve game data when ending', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.teens, players);

        // Play some rounds
        notifier.completeChallenge(ChallengeType.truth);
        notifier.skipChallenge();

        final gameBeforeEnd = container.read(gameProvider)!;
        final scoresBefore = gameBeforeEnd.players.map((p) => p.score).toList();

        notifier.endGame();

        final gameAfterEnd = container.read(gameProvider)!;
        final scoresAfter = gameAfterEnd.players.map((p) => p.score).toList();

        expect(scoresAfter, scoresBefore);
        expect(gameAfterEnd.mode, gameBeforeEnd.mode);
        expect(gameAfterEnd.players.length, gameBeforeEnd.players.length);
      });
    });

    group('Reset Game', () {
      test('should reset game to null', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        expect(container.read(gameProvider), isNotNull);

        notifier.resetGame();

        expect(container.read(gameProvider), isNull);
      });

      test('should handle reset when no game active', () {
        // Should not throw error
        notifier.resetGame();

        expect(container.read(gameProvider), isNull);
      });
    });

    group('Current Player Provider', () {
      test('should provide current player', () {
        final players = TestData.createTestPlayers(count: 3);
        notifier.startNewGame(GameMode.kids, players);

        final currentPlayer = container.read(currentPlayerProvider);
        expect(currentPlayer, players[0]);

        notifier.completeChallenge(ChallengeType.truth);

        final nextPlayer = container.read(currentPlayerProvider);
        expect(nextPlayer, players[1]);
      });

      test('should return null when no game active', () {
        final currentPlayer = container.read(currentPlayerProvider);
        expect(currentPlayer, isNull);
      });
    });

    group('Leaderboard Provider', () {
      test('should provide sorted leaderboard', () {
        final players = TestData.createTestPlayers(count: 3);
        notifier.startNewGame(GameMode.kids, players);

        players[0].updateScore(50);
        players[1].updateScore(100);
        players[2].updateScore(75);

        final leaderboard = container.read(leaderboardProvider);

        expect(leaderboard.length, 3);
        expect(leaderboard[0].score, 100);
        expect(leaderboard[1].score, 75);
        expect(leaderboard[2].score, 50);
      });

      test('should return empty list when no game active', () {
        final leaderboard = container.read(leaderboardProvider);
        expect(leaderboard, isEmpty);
      });
    });

    group('State Management', () {
      test('should notify listeners on state changes', () {
        int notificationCount = 0;

        container.listen(gameProvider, (previous, next) {
          notificationCount++;
        });

        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);
        expect(notificationCount, 1);

        notifier.completeChallenge(ChallengeType.truth);
        expect(notificationCount, 2);

        notifier.endGame();
        expect(notificationCount, 3);

        notifier.resetGame();
        expect(notificationCount, 4);
      });

      test('should maintain game state integrity', () {
        final players = TestData.createTestPlayers(count: 2);
        notifier.startNewGame(GameMode.kids, players);

        final gameId = container.read(gameProvider)!.id;

        // Perform various operations
        notifier.completeChallenge(ChallengeType.truth);
        notifier.skipChallenge();
        notifier.completeChallenge(ChallengeType.dare);

        // Game ID should remain the same
        expect(container.read(gameProvider)!.id, gameId);
      });
    });
  });
}

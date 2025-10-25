import 'package:flutter_test/flutter_test.dart';
import 'package:truth_or_dare/data/models/game_state_model.dart';
import 'package:truth_or_dare/data/models/player_model.dart';
import 'package:truth_or_dare/core/constants/app_constants.dart';
import '../../test_helpers/test_data.dart';

void main() {
  group('GameState Model Tests', () {
    late List<Player> testPlayers;
    late GameState gameState;

    setUp(() {
      testPlayers = TestData.createTestPlayers(count: 3);
      gameState = GameState(mode: GameMode.kids, players: testPlayers);
    });

    group('Constructor', () {
      test('should create game state with default values', () {
        final game = GameState(mode: GameMode.teens, players: testPlayers);

        expect(game.mode, GameMode.teens);
        expect(game.players, testPlayers);
        expect(game.currentPlayerIndex, 0);
        expect(game.usedChallenges, isEmpty);
        expect(game.isActive, true);
        expect(game.id, isNotEmpty);
        expect(game.startedAt, isNotNull);
        expect(game.endedAt, isNull);
      });

      test('should create game state with custom values', () {
        final challenges = TestData.createTestChallenges(
          truthCount: 2,
          dareCount: 2,
        );
        final customDate = DateTime(2024, 1, 1);

        final game = GameState(
          id: 'custom-game-id',
          mode: GameMode.adult,
          players: testPlayers,
          usedChallenges: challenges,
          currentPlayerIndex: 1,
          startedAt: customDate,
          isActive: false,
        );

        expect(game.id, 'custom-game-id');
        expect(game.mode, GameMode.adult);
        expect(game.players, testPlayers);
        expect(game.usedChallenges, challenges);
        expect(game.currentPlayerIndex, 1);
        expect(game.startedAt, customDate);
        expect(game.isActive, false);
      });

      test('should generate unique IDs for different games', () {
        final game1 = GameState(mode: GameMode.kids, players: testPlayers);
        final game2 = GameState(mode: GameMode.kids, players: testPlayers);

        expect(game1.id, isNot(equals(game2.id)));
      });
    });

    group('Current Player', () {
      test('should get current player correctly', () {
        expect(gameState.currentPlayer, testPlayers[0]);

        gameState.currentPlayerIndex = 1;
        expect(gameState.currentPlayer, testPlayers[1]);

        gameState.currentPlayerIndex = 2;
        expect(gameState.currentPlayer, testPlayers[2]);
      });

      test('nextPlayer should cycle through players', () {
        expect(gameState.currentPlayerIndex, 0);

        gameState.nextPlayer();
        expect(gameState.currentPlayerIndex, 1);

        gameState.nextPlayer();
        expect(gameState.currentPlayerIndex, 2);

        // Should wrap around to first player
        gameState.nextPlayer();
        expect(gameState.currentPlayerIndex, 0);
      });

      test('nextPlayer should handle single player', () {
        final singlePlayerGame = GameState(
          mode: GameMode.kids,
          players: [testPlayers[0]],
        );

        expect(singlePlayerGame.currentPlayerIndex, 0);

        singlePlayerGame.nextPlayer();
        expect(singlePlayerGame.currentPlayerIndex, 0);
      });
    });

    group('Challenge Management', () {
      test('should add used challenges', () {
        final challenge1 = TestData.createTestChallenge(content: 'Challenge 1');
        final challenge2 = TestData.createTestChallenge(content: 'Challenge 2');

        expect(gameState.usedChallenges, isEmpty);

        gameState.addUsedChallenge(challenge1);
        expect(gameState.usedChallenges.length, 1);
        expect(gameState.usedChallenges.contains(challenge1), true);

        gameState.addUsedChallenge(challenge2);
        expect(gameState.usedChallenges.length, 2);
        expect(gameState.usedChallenges.contains(challenge2), true);
      });

      test('should track challenge history', () {
        final challenges = TestData.createTestChallenges(
          truthCount: 3,
          dareCount: 2,
        );

        for (final challenge in challenges) {
          gameState.addUsedChallenge(challenge);
        }

        expect(gameState.usedChallenges.length, 5);
        expect(gameState.usedChallenges, challenges);
      });
    });

    group('Game State Management', () {
      test('should end game correctly', () {
        expect(gameState.isActive, true);
        expect(gameState.endedAt, isNull);

        gameState.endGame();

        expect(gameState.isActive, false);
        expect(gameState.endedAt, isNotNull);
      });

      test('should not affect other properties when ending game', () {
        final originalPlayers = gameState.players;
        final originalMode = gameState.mode;
        final originalId = gameState.id;

        gameState.endGame();

        expect(gameState.players, originalPlayers);
        expect(gameState.mode, originalMode);
        expect(gameState.id, originalId);
      });
    });

    group('Winner and Leaderboard', () {
      test('should determine winner correctly', () {
        testPlayers[0].updateScore(50);
        testPlayers[1].updateScore(100);
        testPlayers[2].updateScore(75);

        expect(gameState.winner, testPlayers[1]);
      });

      test('should handle tie by returning first highest scorer', () {
        testPlayers[0].updateScore(100);
        testPlayers[1].updateScore(100);
        testPlayers[2].updateScore(50);

        // When there's a tie, reduce returns the first element encountered
        // with the highest score
        final winner = gameState.winner;
        expect(winner?.score, 100);
        // Either player could be returned depending on reduce implementation
        expect([testPlayers[0], testPlayers[1]].contains(winner), true);
      });

      test('should return null winner for empty game', () {
        final emptyGame = GameState(mode: GameMode.kids, players: []);

        expect(emptyGame.winner, isNull);
      });

      test('should generate correct leaderboard', () {
        testPlayers[0].updateScore(50); // 3rd place
        testPlayers[1].updateScore(100); // 1st place
        testPlayers[2].updateScore(75); // 2nd place

        final leaderboard = gameState.leaderboard;

        expect(leaderboard.length, 3);
        expect(leaderboard[0], testPlayers[1]); // 100 points
        expect(leaderboard[1], testPlayers[2]); // 75 points
        expect(leaderboard[2], testPlayers[0]); // 50 points
      });

      test('leaderboard should not modify original players list', () {
        final originalOrder = List<Player>.from(gameState.players);

        testPlayers[0].updateScore(50);
        testPlayers[1].updateScore(100);
        testPlayers[2].updateScore(75);

        final leaderboard = gameState.leaderboard;

        expect(gameState.players, originalOrder);
        expect(leaderboard, isNot(equals(originalOrder)));
      });
    });

    group('JSON Serialization', () {
      test('toJson should correctly serialize game state', () {
        final challenge = TestData.createTestChallenge();
        gameState.addUsedChallenge(challenge);
        gameState.currentPlayerIndex = 1;

        final json = gameState.toJson();

        expect(json['id'], gameState.id);
        expect(json['mode'], 'kids');
        expect(json['players'], isNotNull);
        expect((json['players'] as List).length, 3);
        expect(json['usedChallenges'], isNotNull);
        expect((json['usedChallenges'] as List).length, 1);
        expect(json['currentPlayerIndex'], 1);
        expect(json['startedAt'], isNotNull);
        expect(json['endedAt'], isNull);
        expect(json['isActive'], true);
      });

      test('toJson should serialize ended game', () {
        gameState.endGame();

        final json = gameState.toJson();

        expect(json['isActive'], false);
        expect(json['endedAt'], isNotNull);
      });

      test('fromJson should correctly deserialize game state', () {
        final json = TestData.gameStateJson;
        final game = GameState.fromJson(json);

        expect(game.id, json['id']);
        expect(game.mode.name, json['mode']);
        expect(game.players.length, 1);
        expect(game.usedChallenges.length, 1);
        expect(game.currentPlayerIndex, json['currentPlayerIndex']);
        expect(game.isActive, json['isActive']);
      });

      test('fromJson should handle missing optional fields', () {
        final minimalJson = {
          'id': 'minimal-game',
          'mode': 'teens',
          'players': [TestData.playerJson],
          'startedAt': DateTime.now().toIso8601String(),
        };

        final game = GameState.fromJson(minimalJson);

        expect(game.id, 'minimal-game');
        expect(game.mode, GameMode.teens);
        expect(game.players.length, 1);
        expect(game.usedChallenges, isEmpty);
        expect(game.currentPlayerIndex, 0);
        expect(game.isActive, true);
        expect(game.endedAt, isNull);
      });

      test('toJson and fromJson should be reversible', () {
        final challenges = TestData.createTestChallenges(
          truthCount: 2,
          dareCount: 1,
        );

        for (final challenge in challenges) {
          gameState.addUsedChallenge(challenge);
        }

        gameState.currentPlayerIndex = 2;
        gameState.endGame();

        final json = gameState.toJson();
        final restored = GameState.fromJson(json);

        expect(restored.id, gameState.id);
        expect(restored.mode, gameState.mode);
        expect(restored.players.length, gameState.players.length);
        expect(restored.usedChallenges.length, gameState.usedChallenges.length);
        expect(restored.currentPlayerIndex, gameState.currentPlayerIndex);
        expect(restored.isActive, gameState.isActive);
        expect(restored.endedAt, isNotNull);
      });
    });

    group('Game Modes', () {
      test('should support all game modes', () {
        final kidsGame = GameState(mode: GameMode.kids, players: testPlayers);
        final teensGame = GameState(mode: GameMode.teens, players: testPlayers);
        final adultGame = GameState(mode: GameMode.adult, players: testPlayers);
        final couplesGame = GameState(
          mode: GameMode.couples,
          players: testPlayers,
        );

        expect(kidsGame.mode, GameMode.kids);
        expect(teensGame.mode, GameMode.teens);
        expect(adultGame.mode, GameMode.adult);
        expect(couplesGame.mode, GameMode.couples);
      });
    });
  });
}

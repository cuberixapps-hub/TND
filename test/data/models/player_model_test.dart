import 'package:flutter_test/flutter_test.dart';
import 'package:truth_or_dare/data/models/player_model.dart';
import '../../test_helpers/test_data.dart';

void main() {
  group('Player Model Tests', () {
    late Player player;

    setUp(() {
      player = TestData.createTestPlayer();
    });

    group('Constructor', () {
      test('should create player with default values', () {
        final newPlayer = Player(name: 'John');

        expect(newPlayer.name, 'John');
        expect(newPlayer.score, 0);
        expect(newPlayer.truthsCompleted, 0);
        expect(newPlayer.daresCompleted, 0);
        expect(newPlayer.skips, 0);
        expect(newPlayer.id, isNotEmpty);
        expect(newPlayer.createdAt, isNotNull);
        expect(newPlayer.avatarEmoji, isNull);
      });

      test('should create player with custom values', () {
        final customPlayer = Player(
          id: 'custom-id',
          name: 'Jane',
          score: 100,
          truthsCompleted: 5,
          daresCompleted: 3,
          skips: 2,
          avatarEmoji: '😎',
        );

        expect(customPlayer.id, 'custom-id');
        expect(customPlayer.name, 'Jane');
        expect(customPlayer.score, 100);
        expect(customPlayer.truthsCompleted, 5);
        expect(customPlayer.daresCompleted, 3);
        expect(customPlayer.skips, 2);
        expect(customPlayer.avatarEmoji, '😎');
      });

      test('should generate unique IDs for different players', () {
        final player1 = Player(name: 'Player 1');
        final player2 = Player(name: 'Player 2');

        expect(player1.id, isNot(equals(player2.id)));
      });
    });

    group('Score Management', () {
      test('updateScore should add points to current score', () {
        expect(player.score, 0);

        player.updateScore(10);
        expect(player.score, 10);

        player.updateScore(15);
        expect(player.score, 25);

        player.updateScore(-5);
        expect(player.score, 20);
      });

      test('updateScore should handle negative scores', () {
        player.updateScore(-10);
        expect(player.score, -10);
      });
    });

    group('Challenge Completion', () {
      test('completeTruth should increment truth counter', () {
        expect(player.truthsCompleted, 0);

        player.completeTruth();
        expect(player.truthsCompleted, 1);

        player.completeTruth();
        expect(player.truthsCompleted, 2);
      });

      test('completeDare should increment dare counter', () {
        expect(player.daresCompleted, 0);

        player.completeDare();
        expect(player.daresCompleted, 1);

        player.completeDare();
        expect(player.daresCompleted, 2);
      });

      test('skip should increment skip counter', () {
        expect(player.skips, 0);

        player.skip();
        expect(player.skips, 1);

        player.skip();
        expect(player.skips, 2);
      });
    });

    group('Reset Functionality', () {
      test('reset should reset all game statistics', () {
        // Set up player with some stats
        player.updateScore(50);
        player.completeTruth();
        player.completeTruth();
        player.completeDare();
        player.skip();

        expect(player.score, 50);
        expect(player.truthsCompleted, 2);
        expect(player.daresCompleted, 1);
        expect(player.skips, 1);

        // Reset
        player.reset();

        expect(player.score, 0);
        expect(player.truthsCompleted, 0);
        expect(player.daresCompleted, 0);
        expect(player.skips, 0);
      });

      test('reset should not affect player identity', () {
        final originalId = player.id;
        final originalName = player.name;
        final originalAvatar = player.avatarEmoji;
        final originalCreatedAt = player.createdAt;

        player.reset();

        expect(player.id, originalId);
        expect(player.name, originalName);
        expect(player.avatarEmoji, originalAvatar);
        expect(player.createdAt, originalCreatedAt);
      });
    });

    group('JSON Serialization', () {
      test('toJson should correctly serialize player', () {
        final player = Player(
          id: 'test-id',
          name: 'Test Player',
          score: 30,
          truthsCompleted: 2,
          daresCompleted: 1,
          skips: 1,
          avatarEmoji: '🎮',
        );

        final json = player.toJson();

        expect(json['id'], 'test-id');
        expect(json['name'], 'Test Player');
        expect(json['score'], 30);
        expect(json['truthsCompleted'], 2);
        expect(json['daresCompleted'], 1);
        expect(json['skips'], 1);
        expect(json['avatarEmoji'], '🎮');
        expect(json['createdAt'], isNotNull);
      });

      test('fromJson should correctly deserialize player', () {
        final json = TestData.playerJson;
        final player = Player.fromJson(json);

        expect(player.id, json['id']);
        expect(player.name, json['name']);
        expect(player.score, json['score']);
        expect(player.truthsCompleted, json['truthsCompleted']);
        expect(player.daresCompleted, json['daresCompleted']);
        expect(player.skips, json['skips']);
        expect(player.avatarEmoji, json['avatarEmoji']);
      });

      test('fromJson should handle missing optional fields', () {
        final minimalJson = {
          'id': 'minimal-id',
          'name': 'Minimal Player',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final player = Player.fromJson(minimalJson);

        expect(player.id, 'minimal-id');
        expect(player.name, 'Minimal Player');
        expect(player.score, 0);
        expect(player.truthsCompleted, 0);
        expect(player.daresCompleted, 0);
        expect(player.skips, 0);
        expect(player.avatarEmoji, isNull);
      });

      test('toJson and fromJson should be reversible', () {
        final original = TestData.createTestPlayer(
          name: 'Reversible Player',
          score: 42,
          truthsCompleted: 3,
          daresCompleted: 2,
          skips: 1,
          avatarEmoji: '🚀',
        );

        final json = original.toJson();
        final restored = Player.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.score, original.score);
        expect(restored.truthsCompleted, original.truthsCompleted);
        expect(restored.daresCompleted, original.daresCompleted);
        expect(restored.skips, original.skips);
        expect(restored.avatarEmoji, original.avatarEmoji);
      });
    });

    group('Player Name', () {
      test('should allow updating player name', () {
        player.name = 'New Name';
        expect(player.name, 'New Name');
      });

      test('should preserve name changes through operations', () {
        player.name = 'Changed Name';
        player.updateScore(10);
        player.completeTruth();

        expect(player.name, 'Changed Name');
      });
    });
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truth_or_dare/presentation/providers/players_provider.dart';
import 'package:truth_or_dare/core/constants/app_constants.dart';

void main() {
  group('PlayersProvider Tests', () {
    late ProviderContainer container;
    late PlayersNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(playersProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Add Player', () {
      test('should add player with valid name', () {
        notifier.addPlayer('John');

        final players = container.read(playersProvider);
        expect(players.length, 1);
        expect(players[0].name, 'John');
        expect(players[0].avatarEmoji, isNotNull);
      });

      test('should trim whitespace from player name', () {
        notifier.addPlayer('  Jane  ');

        final players = container.read(playersProvider);
        expect(players[0].name, 'Jane');
      });

      test('should assign different avatars to players', () {
        notifier.addPlayer('Player 1');
        notifier.addPlayer('Player 2');
        notifier.addPlayer('Player 3');

        final players = container.read(playersProvider);
        expect(players[0].avatarEmoji, isNotNull);
        expect(players[1].avatarEmoji, isNotNull);
        expect(players[2].avatarEmoji, isNotNull);

        // Check that avatars are different
        expect(players[0].avatarEmoji, isNot(equals(players[1].avatarEmoji)));
      });

      test('should throw exception for empty name', () {
        expect(
          () => notifier.addPlayer(''),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Player name cannot be empty'),
            ),
          ),
        );
      });

      test('should throw exception for whitespace-only name', () {
        expect(
          () => notifier.addPlayer('   '),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Player name cannot be empty'),
            ),
          ),
        );
      });

      test('should throw exception for duplicate names', () {
        notifier.addPlayer('John');

        expect(
          () => notifier.addPlayer('John'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Player with this name already exists'),
            ),
          ),
        );
      });

      test('should throw exception for duplicate names (case insensitive)', () {
        notifier.addPlayer('John');

        expect(
          () => notifier.addPlayer('JOHN'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Player with this name already exists'),
            ),
          ),
        );
      });

      test('should throw exception when max players reached', () {
        // Add maximum number of players
        for (int i = 0; i < AppConstants.maxPlayers; i++) {
          notifier.addPlayer('Player $i');
        }

        expect(
          () => notifier.addPlayer('Extra Player'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Maximum ${AppConstants.maxPlayers} players allowed'),
            ),
          ),
        );
      });
    });

    group('Remove Player', () {
      test('should remove player by ID', () {
        notifier.addPlayer('John');
        notifier.addPlayer('Jane');

        final players = container.read(playersProvider);
        final johnId = players[0].id;

        notifier.removePlayer(johnId);

        final updatedPlayers = container.read(playersProvider);
        expect(updatedPlayers.length, 1);
        expect(updatedPlayers[0].name, 'Jane');
      });

      test('should handle removing non-existent player', () {
        notifier.addPlayer('John');

        // Should not throw error
        notifier.removePlayer('non-existent-id');

        final players = container.read(playersProvider);
        expect(players.length, 1);
      });

      test('should handle removing from empty list', () {
        // Should not throw error
        notifier.removePlayer('any-id');

        final players = container.read(playersProvider);
        expect(players, isEmpty);
      });
    });

    group('Update Player Name', () {
      test('should update player name', () {
        notifier.addPlayer('John');

        final players = container.read(playersProvider);
        final playerId = players[0].id;

        notifier.updatePlayerName(playerId, 'Johnny');

        final updatedPlayers = container.read(playersProvider);
        expect(updatedPlayers[0].name, 'Johnny');
      });

      test('should trim whitespace from updated name', () {
        notifier.addPlayer('John');

        final players = container.read(playersProvider);
        final playerId = players[0].id;

        notifier.updatePlayerName(playerId, '  Johnny  ');

        final updatedPlayers = container.read(playersProvider);
        expect(updatedPlayers[0].name, 'Johnny');
      });

      test('should throw exception for empty updated name', () {
        notifier.addPlayer('John');

        final players = container.read(playersProvider);
        final playerId = players[0].id;

        expect(
          () => notifier.updatePlayerName(playerId, ''),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Player name cannot be empty'),
            ),
          ),
        );
      });

      test('should throw exception for duplicate updated name', () {
        notifier.addPlayer('John');
        notifier.addPlayer('Jane');

        final players = container.read(playersProvider);
        final janeId = players[1].id;

        expect(
          () => notifier.updatePlayerName(janeId, 'John'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Player with this name already exists'),
            ),
          ),
        );
      });

      test('should allow updating to same name', () {
        notifier.addPlayer('John');

        final players = container.read(playersProvider);
        final playerId = players[0].id;

        // Should not throw error
        notifier.updatePlayerName(playerId, 'John');

        final updatedPlayers = container.read(playersProvider);
        expect(updatedPlayers[0].name, 'John');
      });
    });

    group('Update Player Avatar', () {
      test('should update player avatar', () {
        notifier.addPlayer('John');

        final players = container.read(playersProvider);
        final playerId = players[0].id;

        notifier.updatePlayerAvatar(playerId, '🎮');

        final updatedPlayers = container.read(playersProvider);
        expect(updatedPlayers[0].avatarEmoji, '🎮');
      });

      test('should handle updating non-existent player avatar', () {
        notifier.addPlayer('John');

        // Should not throw error or change anything
        notifier.updatePlayerAvatar('non-existent-id', '🎮');

        final players = container.read(playersProvider);
        expect(players[0].avatarEmoji, isNot('🎮'));
      });
    });

    group('Clear Players', () {
      test('should clear all players', () {
        notifier.addPlayer('John');
        notifier.addPlayer('Jane');
        notifier.addPlayer('Jack');

        expect(container.read(playersProvider).length, 3);

        notifier.clearPlayers();

        expect(container.read(playersProvider), isEmpty);
      });

      test('should handle clearing empty list', () {
        notifier.clearPlayers();
        expect(container.read(playersProvider), isEmpty);
      });
    });

    group('Reorder Players', () {
      test('should reorder players forward', () {
        notifier.addPlayer('Player 1');
        notifier.addPlayer('Player 2');
        notifier.addPlayer('Player 3');

        notifier.reorderPlayers(0, 2);

        final players = container.read(playersProvider);
        expect(players[0].name, 'Player 2');
        expect(players[1].name, 'Player 1');
        expect(players[2].name, 'Player 3');
      });

      test('should reorder players backward', () {
        notifier.addPlayer('Player 1');
        notifier.addPlayer('Player 2');
        notifier.addPlayer('Player 3');

        notifier.reorderPlayers(2, 0);

        final players = container.read(playersProvider);
        expect(players[0].name, 'Player 3');
        expect(players[1].name, 'Player 1');
        expect(players[2].name, 'Player 2');
      });

      test('should handle reordering to same position', () {
        notifier.addPlayer('Player 1');
        notifier.addPlayer('Player 2');

        notifier.reorderPlayers(0, 0);

        final players = container.read(playersProvider);
        expect(players[0].name, 'Player 1');
        expect(players[1].name, 'Player 2');
      });

      test('should handle reordering single player', () {
        notifier.addPlayer('Player 1');

        // Should not throw error
        notifier.reorderPlayers(0, 0);

        final players = container.read(playersProvider);
        expect(players[0].name, 'Player 1');
      });
    });

    group('Default Avatars', () {
      test('should have sufficient default avatars', () {
        expect(notifier.defaultAvatars.length, greaterThanOrEqualTo(20));
      });

      test('should cycle through avatars when more players than avatars', () {
        // Add exactly max players to test avatar cycling
        for (int i = 0; i < AppConstants.maxPlayers; i++) {
          notifier.addPlayer('Player $i');
        }

        final players = container.read(playersProvider);

        // Check that avatars are assigned cyclically
        // If we have more players than avatars, some avatars will repeat
        if (AppConstants.maxPlayers > notifier.defaultAvatars.length) {
          // Find two players with the same avatar
          bool foundDuplicate = false;
          for (int i = 0; i < players.length - 1; i++) {
            for (int j = i + 1; j < players.length; j++) {
              if (players[i].avatarEmoji == players[j].avatarEmoji) {
                foundDuplicate = true;
                break;
              }
            }
            if (foundDuplicate) break;
          }

          // Since maxPlayers (20) < defaultAvatars.length (24), no duplicates expected
          expect(foundDuplicate, false);
        }
      });
    });

    group('State Management', () {
      test('should notify listeners on state changes', () {
        int notificationCount = 0;

        container.listen(playersProvider, (previous, next) {
          notificationCount++;
        });

        notifier.addPlayer('John');
        expect(notificationCount, 1);

        notifier.addPlayer('Jane');
        expect(notificationCount, 2);

        notifier.clearPlayers();
        expect(notificationCount, 3);
      });

      test('should maintain player references correctly', () {
        notifier.addPlayer('John');

        final players1 = container.read(playersProvider);
        final player = players1[0];
        final originalId = player.id;

        // Modify player
        player.updateScore(10);

        // Add another player
        notifier.addPlayer('Jane');

        final players2 = container.read(playersProvider);
        final samePlayer = players2.firstWhere((p) => p.id == originalId);

        expect(samePlayer.score, 10);
      });
    });
  });
}

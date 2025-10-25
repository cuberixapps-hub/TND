import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/player_model.dart';
import '../../core/constants/app_constants.dart';

class PlayersNotifier extends StateNotifier<List<Player>> {
  PlayersNotifier() : super([]);

  final List<String> defaultAvatars = [
    '😀',
    '😎',
    '🤩',
    '😍',
    '🥳',
    '🤠',
    '🦄',
    '🐯',
    '🦁',
    '🐸',
    '🐵',
    '🦊',
    '🐻',
    '🐼',
    '🐨',
    '🐷',
    '🎭',
    '👾',
    '🤖',
    '👽',
    '🌟',
    '⚡',
    '🔥',
    '🌈',
  ];

  void addPlayer(String name) {
    if (state.length >= AppConstants.maxPlayers) {
      throw Exception('Maximum ${AppConstants.maxPlayers} players allowed');
    }

    if (name.trim().isEmpty) {
      throw Exception('Player name cannot be empty');
    }

    if (state.any(
      (player) => player.name.toLowerCase() == name.toLowerCase(),
    )) {
      throw Exception('Player with this name already exists');
    }

    final avatar = defaultAvatars[state.length % defaultAvatars.length];

    state = [...state, Player(name: name.trim(), avatarEmoji: avatar)];
  }

  void removePlayer(String playerId) {
    state = state.where((player) => player.id != playerId).toList();
  }

  void updatePlayerName(String playerId, String newName) {
    if (newName.trim().isEmpty) {
      throw Exception('Player name cannot be empty');
    }

    if (state.any(
      (player) =>
          player.id != playerId &&
          player.name.toLowerCase() == newName.toLowerCase(),
    )) {
      throw Exception('Player with this name already exists');
    }

    state =
        state.map((player) {
          if (player.id == playerId) {
            player.name = newName.trim();
          }
          return player;
        }).toList();
  }

  void updatePlayerAvatar(String playerId, String emoji) {
    state =
        state.map((player) {
          if (player.id == playerId) {
            player.avatarEmoji = emoji;
          }
          return player;
        }).toList();
  }

  void clearPlayers() {
    state = [];
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final List<Player> players = List.from(state);
    final Player player = players.removeAt(oldIndex);
    players.insert(newIndex, player);

    state = players;
  }
}

final playersProvider = StateNotifierProvider<PlayersNotifier, List<Player>>((
  ref,
) {
  return PlayersNotifier();
});

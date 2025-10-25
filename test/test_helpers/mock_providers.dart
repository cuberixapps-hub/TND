import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truth_or_dare/data/models/player_model.dart';
import 'package:truth_or_dare/data/models/challenge_model.dart';
import 'package:truth_or_dare/data/models/game_state_model.dart';
import 'package:truth_or_dare/presentation/providers/players_provider.dart';
import 'package:truth_or_dare/presentation/providers/game_provider.dart';
import 'package:truth_or_dare/presentation/providers/custom_challenges_provider.dart';

// Mock provider overrides for testing
class MockProviders {
  static List<Override> getDefaultOverrides({
    List<Player>? players,
    GameState? gameState,
    List<Challenge>? customChallenges,
  }) {
    return [
      if (players != null)
        playersProvider.overrideWith((ref) {
          return PlayersNotifier()..state = players;
        }),
      if (gameState != null)
        gameProvider.overrideWith((ref) {
          return GameNotifier(ref)..state = gameState;
        }),
      if (customChallenges != null)
        customChallengesProvider.overrideWith((ref) {
          return CustomChallengesNotifier()..state = customChallenges;
        }),
    ];
  }

  static ProviderContainer createContainer({
    List<Player>? players,
    GameState? gameState,
    List<Challenge>? customChallenges,
  }) {
    return ProviderContainer(
      overrides: getDefaultOverrides(
        players: players,
        gameState: gameState,
        customChallenges: customChallenges,
      ),
    );
  }
}


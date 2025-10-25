import 'package:truth_or_dare/data/models/player_model.dart';
import 'package:truth_or_dare/data/models/challenge_model.dart';
import 'package:truth_or_dare/core/constants/app_constants.dart';

class TestData {
  // Sample Players
  static Player createTestPlayer({
    String? id,
    String name = 'Test Player',
    int score = 0,
    int truthsCompleted = 0,
    int daresCompleted = 0,
    int skips = 0,
    String? avatarEmoji,
  }) {
    return Player(
      id: id,
      name: name,
      score: score,
      truthsCompleted: truthsCompleted,
      daresCompleted: daresCompleted,
      skips: skips,
      avatarEmoji: avatarEmoji ?? '😀',
    );
  }

  static List<Player> createTestPlayers({int count = 3}) {
    return List.generate(
      count,
      (index) => createTestPlayer(
        name: 'Player ${index + 1}',
        avatarEmoji: ['😀', '😎', '🤩', '😍', '🥳'][index % 5],
      ),
    );
  }

  // Sample Challenges
  static Challenge createTestChallenge({
    String? id,
    String content = 'Test Challenge',
    ChallengeType type = ChallengeType.truth,
    GameMode mode = GameMode.kids,
    int difficulty = 3,
    bool isCustom = false,
    List<String>? tags,
  }) {
    return Challenge(
      id: id,
      content: content,
      type: type,
      mode: mode,
      difficulty: difficulty,
      isCustom: isCustom,
      tags: tags,
    );
  }

  static List<Challenge> createTestChallenges({
    int truthCount = 5,
    int dareCount = 5,
    GameMode mode = GameMode.kids,
  }) {
    final challenges = <Challenge>[];

    for (int i = 0; i < truthCount; i++) {
      challenges.add(
        createTestChallenge(
          content: 'Truth Challenge ${i + 1}',
          type: ChallengeType.truth,
          mode: mode,
          difficulty: (i % 5) + 1,
        ),
      );
    }

    for (int i = 0; i < dareCount; i++) {
      challenges.add(
        createTestChallenge(
          content: 'Dare Challenge ${i + 1}',
          type: ChallengeType.dare,
          mode: mode,
          difficulty: (i % 5) + 1,
        ),
      );
    }

    return challenges;
  }

  // Test JSON data
  static Map<String, dynamic> playerJson = {
    'id': 'test-player-id',
    'name': 'John Doe',
    'score': 50,
    'truthsCompleted': 3,
    'daresCompleted': 2,
    'skips': 1,
    'createdAt': DateTime.now().toIso8601String(),
    'avatarEmoji': '😎',
  };

  static Map<String, dynamic> challengeJson = {
    'id': 'test-challenge-id',
    'content': 'What is your biggest fear?',
    'type': 'truth',
    'mode': 'kids',
    'difficulty': 3,
    'isCustom': false,
    'createdAt': DateTime.now().toIso8601String(),
    'tags': ['personal', 'emotional'],
  };

  static Map<String, dynamic> gameStateJson = {
    'id': 'test-game-id',
    'mode': 'kids',
    'players': [playerJson],
    'usedChallenges': [challengeJson],
    'currentPlayerIndex': 0,
    'startedAt': DateTime.now().toIso8601String(),
    'endedAt': null,
    'isActive': true,
  };
}


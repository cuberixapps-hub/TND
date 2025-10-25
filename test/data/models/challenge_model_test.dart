import 'package:flutter_test/flutter_test.dart';
import 'package:truth_or_dare/data/models/challenge_model.dart';
import 'package:truth_or_dare/core/constants/app_constants.dart';
import '../../test_helpers/test_data.dart';

void main() {
  group('Challenge Model Tests', () {
    group('Constructor', () {
      test('should create challenge with default values', () {
        final challenge = Challenge(
          content: 'Test Challenge',
          type: ChallengeType.truth,
          mode: GameMode.kids,
        );

        expect(challenge.content, 'Test Challenge');
        expect(challenge.type, ChallengeType.truth);
        expect(challenge.mode, GameMode.kids);
        expect(challenge.difficulty, 3); // default
        expect(challenge.isCustom, false); // default
        expect(challenge.id, isNotEmpty);
        expect(challenge.createdAt, isNotNull);
        expect(challenge.tags, isNull);
      });

      test('should create challenge with custom values', () {
        final tags = ['funny', 'easy'];
        final customDate = DateTime(2024, 1, 1);
        final challenge = Challenge(
          id: 'custom-id',
          content: 'Custom Challenge',
          type: ChallengeType.dare,
          mode: GameMode.adult,
          difficulty: 5,
          isCustom: true,
          createdAt: customDate,
          tags: tags,
        );

        expect(challenge.id, 'custom-id');
        expect(challenge.content, 'Custom Challenge');
        expect(challenge.type, ChallengeType.dare);
        expect(challenge.mode, GameMode.adult);
        expect(challenge.difficulty, 5);
        expect(challenge.isCustom, true);
        expect(challenge.createdAt, customDate);
        expect(challenge.tags, tags);
      });

      test('should generate unique IDs for different challenges', () {
        final challenge1 = Challenge(
          content: 'Challenge 1',
          type: ChallengeType.truth,
          mode: GameMode.kids,
        );
        final challenge2 = Challenge(
          content: 'Challenge 2',
          type: ChallengeType.dare,
          mode: GameMode.kids,
        );

        expect(challenge1.id, isNot(equals(challenge2.id)));
      });

      test('should validate difficulty range', () {
        final challenge1 = Challenge(
          content: 'Easy',
          type: ChallengeType.truth,
          mode: GameMode.kids,
          difficulty: 1,
        );
        final challenge5 = Challenge(
          content: 'Hard',
          type: ChallengeType.truth,
          mode: GameMode.kids,
          difficulty: 5,
        );

        expect(challenge1.difficulty, 1);
        expect(challenge5.difficulty, 5);
      });
    });

    group('Challenge Types', () {
      test('should create truth challenge', () {
        final truth = Challenge(
          content: 'What is your biggest fear?',
          type: ChallengeType.truth,
          mode: GameMode.teens,
        );

        expect(truth.type, ChallengeType.truth);
        expect(truth.type.label, 'Truth');
        expect(truth.type.emoji, '🤔');
      });

      test('should create dare challenge', () {
        final dare = Challenge(
          content: 'Do 10 pushups',
          type: ChallengeType.dare,
          mode: GameMode.teens,
        );

        expect(dare.type, ChallengeType.dare);
        expect(dare.type.label, 'Dare');
        expect(dare.type.emoji, '😈');
      });
    });

    group('Game Modes', () {
      test('should support kids mode', () {
        final challenge = Challenge(
          content: 'Kids challenge',
          type: ChallengeType.truth,
          mode: GameMode.kids,
        );

        expect(challenge.mode, GameMode.kids);
        expect(challenge.mode.label, 'Kids');
        expect(challenge.mode.emoji, '👶');
      });

      test('should support teens mode', () {
        final challenge = Challenge(
          content: 'Teens challenge',
          type: ChallengeType.truth,
          mode: GameMode.teens,
        );

        expect(challenge.mode, GameMode.teens);
        expect(challenge.mode.label, 'Teens');
        expect(challenge.mode.emoji, '🎉');
      });

      test('should support adult mode', () {
        final challenge = Challenge(
          content: 'Adult challenge',
          type: ChallengeType.truth,
          mode: GameMode.adult,
        );

        expect(challenge.mode, GameMode.adult);
        expect(challenge.mode.label, 'Adult');
        expect(challenge.mode.emoji, '🔥');
      });

      test('should support couples mode', () {
        final challenge = Challenge(
          content: 'Couples challenge',
          type: ChallengeType.truth,
          mode: GameMode.couples,
        );

        expect(challenge.mode, GameMode.couples);
        expect(challenge.mode.label, 'Couples');
        expect(challenge.mode.emoji, '💕');
      });
    });

    group('JSON Serialization', () {
      test('toJson should correctly serialize challenge', () {
        final tags = ['funny', 'creative'];
        final challenge = Challenge(
          id: 'test-id',
          content: 'Test Content',
          type: ChallengeType.dare,
          mode: GameMode.teens,
          difficulty: 4,
          isCustom: true,
          tags: tags,
        );

        final json = challenge.toJson();

        expect(json['id'], 'test-id');
        expect(json['content'], 'Test Content');
        expect(json['type'], 'dare');
        expect(json['mode'], 'teens');
        expect(json['difficulty'], 4);
        expect(json['isCustom'], true);
        expect(json['createdAt'], isNotNull);
        expect(json['tags'], tags);
      });

      test('fromJson should correctly deserialize challenge', () {
        final json = TestData.challengeJson;
        final challenge = Challenge.fromJson(json);

        expect(challenge.id, json['id']);
        expect(challenge.content, json['content']);
        expect(challenge.type.name, json['type']);
        expect(challenge.mode.name, json['mode']);
        expect(challenge.difficulty, json['difficulty']);
        expect(challenge.isCustom, json['isCustom']);
        expect(challenge.tags, json['tags']);
      });

      test('fromJson should handle missing optional fields', () {
        final minimalJson = {
          'id': 'minimal-id',
          'content': 'Minimal Challenge',
          'type': 'truth',
          'mode': 'kids',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final challenge = Challenge.fromJson(minimalJson);

        expect(challenge.id, 'minimal-id');
        expect(challenge.content, 'Minimal Challenge');
        expect(challenge.type, ChallengeType.truth);
        expect(challenge.mode, GameMode.kids);
        expect(challenge.difficulty, 3); // default
        expect(challenge.isCustom, false); // default
        expect(challenge.tags, isNull);
      });

      test('toJson and fromJson should be reversible', () {
        final original = TestData.createTestChallenge(
          content: 'Reversible Challenge',
          type: ChallengeType.dare,
          mode: GameMode.adult,
          difficulty: 5,
          isCustom: true,
          tags: ['tag1', 'tag2'],
        );

        final json = original.toJson();
        final restored = Challenge.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.content, original.content);
        expect(restored.type, original.type);
        expect(restored.mode, original.mode);
        expect(restored.difficulty, original.difficulty);
        expect(restored.isCustom, original.isCustom);
        expect(restored.tags, original.tags);
      });
    });

    group('Custom Challenges', () {
      test('should differentiate between custom and preloaded challenges', () {
        final preloaded = Challenge(
          content: 'Preloaded',
          type: ChallengeType.truth,
          mode: GameMode.kids,
          isCustom: false,
        );

        final custom = Challenge(
          content: 'Custom',
          type: ChallengeType.truth,
          mode: GameMode.kids,
          isCustom: true,
        );

        expect(preloaded.isCustom, false);
        expect(custom.isCustom, true);
      });
    });

    group('Tags', () {
      test('should support tags for categorization', () {
        final challenge = Challenge(
          content: 'Tagged Challenge',
          type: ChallengeType.truth,
          mode: GameMode.teens,
          tags: ['funny', 'embarrassing', 'social'],
        );

        expect(challenge.tags, isNotNull);
        expect(challenge.tags!.length, 3);
        expect(challenge.tags!.contains('funny'), true);
        expect(challenge.tags!.contains('embarrassing'), true);
        expect(challenge.tags!.contains('social'), true);
      });

      test('should handle challenges without tags', () {
        final challenge = Challenge(
          content: 'No Tags',
          type: ChallengeType.truth,
          mode: GameMode.kids,
        );

        expect(challenge.tags, isNull);
      });
    });
  });
}


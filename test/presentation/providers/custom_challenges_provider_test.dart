import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truth_or_dare/presentation/providers/custom_challenges_provider.dart';
import 'package:truth_or_dare/data/models/challenge_model.dart';
import 'package:truth_or_dare/core/constants/app_constants.dart';
import '../../test_helpers/test_data.dart';

void main() {
  group('CustomChallengesProvider Tests', () {
    late ProviderContainer container;
    late CustomChallengesNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(customChallengesProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Add Challenge', () {
      test('should add custom challenge', () {
        final challenge = TestData.createTestChallenge(
          content: 'Custom Challenge',
          isCustom: true,
        );

        notifier.addChallenge(challenge);

        final challenges = container.read(customChallengesProvider);
        expect(challenges.length, 1);
        expect(challenges[0], challenge);
        expect(challenges[0].isCustom, true);
      });

      test('should add multiple challenges', () {
        final challenge1 = TestData.createTestChallenge(
          content: 'Challenge 1',
          isCustom: true,
        );
        final challenge2 = TestData.createTestChallenge(
          content: 'Challenge 2',
          type: ChallengeType.dare,
          isCustom: true,
        );

        notifier.addChallenge(challenge1);
        notifier.addChallenge(challenge2);

        final challenges = container.read(customChallengesProvider);
        expect(challenges.length, 2);
        expect(challenges.contains(challenge1), true);
        expect(challenges.contains(challenge2), true);
      });

      test('should preserve challenge properties', () {
        final challenge = Challenge(
          content: 'Test Content',
          type: ChallengeType.dare,
          mode: GameMode.adult,
          difficulty: 5,
          isCustom: true,
          tags: ['tag1', 'tag2'],
        );

        notifier.addChallenge(challenge);

        final storedChallenge = container.read(customChallengesProvider)[0];
        expect(storedChallenge.content, challenge.content);
        expect(storedChallenge.type, challenge.type);
        expect(storedChallenge.mode, challenge.mode);
        expect(storedChallenge.difficulty, challenge.difficulty);
        expect(storedChallenge.isCustom, challenge.isCustom);
        expect(storedChallenge.tags, challenge.tags);
      });
    });

    group('Remove Challenge', () {
      test('should remove challenge by ID', () {
        final challenge1 = TestData.createTestChallenge(content: 'Challenge 1');
        final challenge2 = TestData.createTestChallenge(content: 'Challenge 2');

        notifier.addChallenge(challenge1);
        notifier.addChallenge(challenge2);

        expect(container.read(customChallengesProvider).length, 2);

        notifier.removeChallenge(challenge1.id);

        final challenges = container.read(customChallengesProvider);
        expect(challenges.length, 1);
        expect(challenges[0], challenge2);
      });

      test('should handle removing non-existent challenge', () {
        final challenge = TestData.createTestChallenge();
        notifier.addChallenge(challenge);

        // Should not throw error
        notifier.removeChallenge('non-existent-id');

        final challenges = container.read(customChallengesProvider);
        expect(challenges.length, 1);
      });

      test('should handle removing from empty list', () {
        // Should not throw error
        notifier.removeChallenge('any-id');

        final challenges = container.read(customChallengesProvider);
        expect(challenges, isEmpty);
      });
    });

    group('Update Challenge', () {
      test('should update existing challenge', () {
        final originalChallenge = TestData.createTestChallenge(
          content: 'Original Content',
          difficulty: 3,
        );

        notifier.addChallenge(originalChallenge);

        final updatedChallenge = Challenge(
          id: originalChallenge.id,
          content: 'Updated Content',
          type: originalChallenge.type,
          mode: originalChallenge.mode,
          difficulty: 5,
          isCustom: true,
        );

        notifier.updateChallenge(updatedChallenge);

        final challenges = container.read(customChallengesProvider);
        expect(challenges.length, 1);
        expect(challenges[0].id, originalChallenge.id);
        expect(challenges[0].content, 'Updated Content');
        expect(challenges[0].difficulty, 5);
        expect(challenges[0].isCustom, true);
      });

      test('should not affect other challenges when updating', () {
        final challenge1 = TestData.createTestChallenge(content: 'Challenge 1');
        final challenge2 = TestData.createTestChallenge(content: 'Challenge 2');
        final challenge3 = TestData.createTestChallenge(content: 'Challenge 3');

        notifier.addChallenge(challenge1);
        notifier.addChallenge(challenge2);
        notifier.addChallenge(challenge3);

        final updatedChallenge2 = Challenge(
          id: challenge2.id,
          content: 'Updated Challenge 2',
          type: challenge2.type,
          mode: challenge2.mode,
        );

        notifier.updateChallenge(updatedChallenge2);

        final challenges = container.read(customChallengesProvider);
        expect(challenges.length, 3);
        expect(challenges[0].content, 'Challenge 1');
        expect(challenges[1].content, 'Updated Challenge 2');
        expect(challenges[2].content, 'Challenge 3');
      });

      test('should handle updating non-existent challenge', () {
        final challenge = TestData.createTestChallenge();
        notifier.addChallenge(challenge);

        final nonExistentChallenge = TestData.createTestChallenge(
          id: 'non-existent-id',
          content: 'Non-existent',
        );

        notifier.updateChallenge(nonExistentChallenge);

        final challenges = container.read(customChallengesProvider);
        expect(challenges.length, 1);
        expect(challenges[0], challenge); // Original unchanged
      });
    });

    group('Get Challenges For Mode', () {
      test('should filter challenges by game mode', () {
        final kidsChallenge1 = TestData.createTestChallenge(
          content: 'Kids 1',
          mode: GameMode.kids,
        );
        final kidsChallenge2 = TestData.createTestChallenge(
          content: 'Kids 2',
          mode: GameMode.kids,
        );
        final teensChallenge = TestData.createTestChallenge(
          content: 'Teens 1',
          mode: GameMode.teens,
        );
        final adultChallenge = TestData.createTestChallenge(
          content: 'Adult 1',
          mode: GameMode.adult,
        );

        notifier.addChallenge(kidsChallenge1);
        notifier.addChallenge(kidsChallenge2);
        notifier.addChallenge(teensChallenge);
        notifier.addChallenge(adultChallenge);

        final kidsChallenges = notifier.getChallengesForMode(GameMode.kids);
        expect(kidsChallenges.length, 2);
        expect(kidsChallenges.every((c) => c.mode == GameMode.kids), true);

        final teensChallenges = notifier.getChallengesForMode(GameMode.teens);
        expect(teensChallenges.length, 1);
        expect(teensChallenges[0].mode, GameMode.teens);

        final adultChallenges = notifier.getChallengesForMode(GameMode.adult);
        expect(adultChallenges.length, 1);
        expect(adultChallenges[0].mode, GameMode.adult);

        final couplesChallenges = notifier.getChallengesForMode(
          GameMode.couples,
        );
        expect(couplesChallenges, isEmpty);
      });

      test('should return empty list for mode with no challenges', () {
        final challenge = TestData.createTestChallenge(mode: GameMode.kids);
        notifier.addChallenge(challenge);

        final couplesChallenges = notifier.getChallengesForMode(
          GameMode.couples,
        );
        expect(couplesChallenges, isEmpty);
      });
    });

    group('Clear All Challenges', () {
      test('should clear all challenges', () {
        final challenges = TestData.createTestChallenges(
          truthCount: 3,
          dareCount: 2,
        );

        for (final challenge in challenges) {
          notifier.addChallenge(challenge);
        }

        expect(container.read(customChallengesProvider).length, 5);

        notifier.clearAllChallenges();

        expect(container.read(customChallengesProvider), isEmpty);
      });

      test('should handle clearing empty list', () {
        notifier.clearAllChallenges();
        expect(container.read(customChallengesProvider), isEmpty);
      });
    });

    group('Challenge Types', () {
      test('should support both truth and dare challenges', () {
        final truthChallenge = TestData.createTestChallenge(
          type: ChallengeType.truth,
        );
        final dareChallenge = TestData.createTestChallenge(
          type: ChallengeType.dare,
        );

        notifier.addChallenge(truthChallenge);
        notifier.addChallenge(dareChallenge);

        final challenges = container.read(customChallengesProvider);
        final truths = challenges.where((c) => c.type == ChallengeType.truth);
        final dares = challenges.where((c) => c.type == ChallengeType.dare);

        expect(truths.length, 1);
        expect(dares.length, 1);
      });
    });

    group('State Management', () {
      test('should notify listeners on state changes', () {
        int notificationCount = 0;

        container.listen(customChallengesProvider, (previous, next) {
          notificationCount++;
        });

        final challenge = TestData.createTestChallenge();

        notifier.addChallenge(challenge);
        expect(notificationCount, 1);

        notifier.updateChallenge(challenge);
        expect(notificationCount, 2);

        notifier.removeChallenge(challenge.id);
        expect(notificationCount, 3);

        notifier.clearAllChallenges();
        expect(notificationCount, 4);
      });

      test('should maintain challenge order', () {
        final challenge1 = TestData.createTestChallenge(content: 'First');
        final challenge2 = TestData.createTestChallenge(content: 'Second');
        final challenge3 = TestData.createTestChallenge(content: 'Third');

        notifier.addChallenge(challenge1);
        notifier.addChallenge(challenge2);
        notifier.addChallenge(challenge3);

        final challenges = container.read(customChallengesProvider);
        expect(challenges[0].content, 'First');
        expect(challenges[1].content, 'Second');
        expect(challenges[2].content, 'Third');
      });
    });

    group('Initial State', () {
      test('should start with empty challenges list', () {
        final challenges = container.read(customChallengesProvider);
        expect(challenges, isEmpty);
      });

      test('should load challenges on initialization', () async {
        // The notifier calls _loadChallenges in constructor
        // Wait a bit for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        // In the actual implementation, this would load from Hive
        // For now, it should still be empty as Hive is not configured
        final challenges = container.read(customChallengesProvider);
        expect(challenges, isEmpty);
      });
    });
  });
}


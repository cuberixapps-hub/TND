import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/challenge_model.dart';
import '../../core/constants/app_constants.dart';

class CustomChallengesNotifier extends StateNotifier<List<Challenge>> {
  CustomChallengesNotifier() : super([]) {
    _loadChallenges();
  }

  // late Box<Challenge>? _challengesBox;

  Future<void> _loadChallenges() async {
    try {
      // Note: In a real app, you would register the Hive adapter for Challenge
      // and open the box. For now, we'll just use in-memory storage
      // _challengesBox = await Hive.openBox<Challenge>(AppConstants.customChallengesBoxKey);
      // state = _challengesBox!.values.toList();
    } catch (e) {
      // Handle error
    }
  }

  void addChallenge(Challenge challenge) {
    state = [...state, challenge];
    // In a real app, you would also save to Hive:
    // _challengesBox?.put(challenge.id, challenge);
  }

  void removeChallenge(String challengeId) {
    state = state.where((c) => c.id != challengeId).toList();
    // In a real app, you would also delete from Hive:
    // _challengesBox?.delete(challengeId);
  }

  void updateChallenge(Challenge challenge) {
    state = state.map((c) => c.id == challenge.id ? challenge : c).toList();
    // In a real app, you would also update in Hive:
    // _challengesBox?.put(challenge.id, challenge);
  }

  List<Challenge> getChallengesForMode(GameMode mode) {
    return state.where((c) => c.mode == mode).toList();
  }

  void clearAllChallenges() {
    state = [];
    // In a real app, you would also clear Hive:
    // _challengesBox?.clear();
  }
}

final customChallengesProvider =
    StateNotifierProvider<CustomChallengesNotifier, List<Challenge>>((ref) {
      return CustomChallengesNotifier();
    });

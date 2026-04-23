import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/challenge_model.dart';

/// Persistent store of user-authored truths and dares.
///
/// Prior to 1.0.3 this notifier held challenges in memory only, so any
/// custom content the user wrote was lost on app restart. 1.0.3 persists
/// the full list to a Hive box as JSON strings so users can build up a
/// personal, reusable pack of challenges over time — one of the core
/// features that differentiates this app from generic truth-or-dare apps
/// in the category.
class CustomChallengesNotifier extends StateNotifier<List<Challenge>> {
  CustomChallengesNotifier() : super(const <Challenge>[]) {
    _load();
  }

  static const String _boxName = 'custom_challenges_box';
  static const String _entriesKey = 'entries';

  Box<dynamic>? _box;

  Future<void> _ensureBox() async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
  }

  Future<void> _load() async {
    try {
      await _ensureBox();
      final dynamic raw = _box!.get(_entriesKey);
      if (raw is List) {
        final parsed = <Challenge>[];
        for (final dynamic entry in raw) {
          if (entry is String && entry.isNotEmpty) {
            try {
              final decoded = jsonDecode(entry) as Map<String, dynamic>;
              parsed.add(Challenge.fromJson(decoded));
            } catch (e) {
              debugPrint('Skipping malformed custom challenge: $e');
            }
          }
        }
        state = parsed;
      }
    } catch (e) {
      debugPrint('Failed to load custom challenges: $e');
    }
  }

  Future<void> _persist() async {
    try {
      await _ensureBox();
      final encoded = state
          .map((c) => jsonEncode(c.toJson()))
          .toList(growable: false);
      await _box!.put(_entriesKey, encoded);
    } catch (e) {
      debugPrint('Failed to persist custom challenges: $e');
    }
  }

  Future<void> addChallenge(Challenge challenge) async {
    // Force isCustom true so the rest of the app can recognise these.
    final entry = challenge.isCustom
        ? challenge
        : Challenge(
            id: challenge.id,
            content: challenge.content,
            type: challenge.type,
            mode: challenge.mode,
            difficulty: challenge.difficulty,
            isCustom: true,
            createdAt: challenge.createdAt,
            tags: challenge.tags,
          );
    state = [...state, entry];
    await _persist();
  }

  Future<void> removeChallenge(String challengeId) async {
    state = state.where((c) => c.id != challengeId).toList(growable: false);
    await _persist();
  }

  Future<void> updateChallenge(Challenge challenge) async {
    state = state
        .map((c) => c.id == challenge.id ? challenge : c)
        .toList(growable: false);
    await _persist();
  }

  List<Challenge> getChallengesForMode(GameMode mode) {
    return state.where((c) => c.mode == mode).toList(growable: false);
  }

  Future<void> clearAllChallenges() async {
    state = const <Challenge>[];
    await _persist();
  }

  /// Bulk-import a set of challenges (used by share / import flows).
  Future<void> importChallenges(Iterable<Challenge> challenges) async {
    state = [...state, ...challenges];
    await _persist();
  }
}

final customChallengesProvider =
    StateNotifierProvider<CustomChallengesNotifier, List<Challenge>>(
      (ref) => CustomChallengesNotifier(),
    );

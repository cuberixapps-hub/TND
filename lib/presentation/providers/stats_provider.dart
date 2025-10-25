import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/game_state_model.dart';
import '../../core/extensions/enum_extensions.dart';
import '../../data/models/player_model.dart';

// Game statistics model
class GameStats {
  final int totalGamesPlayed;
  final int totalPlayers;
  final int totalChallenges;
  final int truthsCompleted;
  final int daresCompleted;
  final int totalWins;
  final double averageWinRate;
  final int kidsGamesPlayed;
  final int teensGamesPlayed;
  final int adultGamesPlayed;
  final int couplesGamesPlayed;
  final int longestStreak;
  final DateTime? lastPlayed;

  GameStats({
    required this.totalGamesPlayed,
    required this.totalPlayers,
    required this.totalChallenges,
    required this.truthsCompleted,
    required this.daresCompleted,
    required this.totalWins,
    required this.averageWinRate,
    required this.kidsGamesPlayed,
    required this.teensGamesPlayed,
    required this.adultGamesPlayed,
    required this.couplesGamesPlayed,
    required this.longestStreak,
    this.lastPlayed,
  });

  factory GameStats.empty() => GameStats(
    totalGamesPlayed: 0,
    totalPlayers: 0,
    totalChallenges: 0,
    truthsCompleted: 0,
    daresCompleted: 0,
    totalWins: 0,
    averageWinRate: 0,
    kidsGamesPlayed: 0,
    teensGamesPlayed: 0,
    adultGamesPlayed: 0,
    couplesGamesPlayed: 0,
    longestStreak: 0,
    lastPlayed: null,
  );

  Map<String, dynamic> toJson() => {
    'totalGamesPlayed': totalGamesPlayed,
    'totalPlayers': totalPlayers,
    'totalChallenges': totalChallenges,
    'truthsCompleted': truthsCompleted,
    'daresCompleted': daresCompleted,
    'totalWins': totalWins,
    'averageWinRate': averageWinRate,
    'kidsGamesPlayed': kidsGamesPlayed,
    'teensGamesPlayed': teensGamesPlayed,
    'adultGamesPlayed': adultGamesPlayed,
    'couplesGamesPlayed': couplesGamesPlayed,
    'longestStreak': longestStreak,
    'lastPlayed': lastPlayed?.toIso8601String(),
  };

  factory GameStats.fromJson(Map<String, dynamic> json) => GameStats(
    totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
    totalPlayers: json['totalPlayers'] ?? 0,
    totalChallenges: json['totalChallenges'] ?? 0,
    truthsCompleted: json['truthsCompleted'] ?? 0,
    daresCompleted: json['daresCompleted'] ?? 0,
    totalWins: json['totalWins'] ?? 0,
    averageWinRate: (json['averageWinRate'] ?? 0).toDouble(),
    kidsGamesPlayed: json['kidsGamesPlayed'] ?? 0,
    teensGamesPlayed: json['teensGamesPlayed'] ?? 0,
    adultGamesPlayed: json['adultGamesPlayed'] ?? 0,
    couplesGamesPlayed: json['couplesGamesPlayed'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    lastPlayed:
        json['lastPlayed'] != null ? DateTime.parse(json['lastPlayed']) : null,
  );
}

// Stats notifier
class StatsNotifier extends StateNotifier<GameStats> {
  static const String _boxName = 'gameStats';
  static const String _statsKey = 'stats';
  Box? _box;

  StatsNotifier() : super(GameStats.empty()) {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      _box = await Hive.openBox(_boxName);
      _loadStats();
    } catch (e) {
      print('Error initializing stats box: $e');
    }
  }

  void _loadStats() {
    if (_box == null) return;

    final data = _box!.get(_statsKey);
    if (data != null) {
      state = GameStats.fromJson(Map<String, dynamic>.from(data));
    }
  }

  void _saveStats() {
    if (_box == null) {
      print('Stats box not initialized, cannot save stats');
      return;
    }
    _box!.put(_statsKey, state.toJson());
  }

  void recordGameEnd(GameState gameState) {
    if (!gameState.isActive) return;

    // Skip stats recording if box is not initialized
    if (_box == null) {
      print('Stats box not initialized, skipping stats recording');
      return;
    }

    // Calculate game statistics
    final totalChallenges = gameState.players.fold<int>(
      0,
      (int sum, Player player) =>
          sum + player.truthsCompleted + player.daresCompleted,
    );

    final truthsInGame = gameState.players.fold<int>(
      0,
      (int sum, Player player) => sum + player.truthsCompleted,
    );

    final daresInGame = gameState.players.fold<int>(
      0,
      (int sum, Player player) => sum + player.daresCompleted,
    );

    // Find winner
    final sortedPlayers = List<Player>.from(gameState.players)
      ..sort((a, b) => b.score.compareTo(a.score));
    final hasWinner = sortedPlayers.isNotEmpty && sortedPlayers.first.score > 0;

    // Get mode-specific count
    int kidsGames = state.kidsGamesPlayed;
    int teensGames = state.teensGamesPlayed;
    int adultGames = state.adultGamesPlayed;
    int couplesGames = state.couplesGamesPlayed;

    switch (gameState.mode.enumName) {
      case 'kids':
        kidsGames++;
        break;
      case 'teens':
        teensGames++;
        break;
      case 'adult':
        adultGames++;
        break;
      case 'couples':
        couplesGames++;
        break;
    }

    // Calculate new average win rate
    final newTotalGames = state.totalGamesPlayed + 1;
    final newTotalWins = state.totalWins + (hasWinner ? 1 : 0);
    final newWinRate =
        newTotalGames > 0 ? (newTotalWins / newTotalGames * 100) : 0.0;

    // Update stats
    state = GameStats(
      totalGamesPlayed: newTotalGames,
      totalPlayers: state.totalPlayers + gameState.players.length,
      totalChallenges: state.totalChallenges + totalChallenges,
      truthsCompleted: state.truthsCompleted + truthsInGame,
      daresCompleted: state.daresCompleted + daresInGame,
      totalWins: newTotalWins,
      averageWinRate: newWinRate,
      kidsGamesPlayed: kidsGames,
      teensGamesPlayed: teensGames,
      adultGamesPlayed: adultGames,
      couplesGamesPlayed: couplesGames,
      longestStreak: state.longestStreak, // TODO: Track winning streaks
      lastPlayed: DateTime.now(),
    );

    _saveStats();
  }

  void clearStats() {
    state = GameStats.empty();
    if (_box != null) {
      _box!.delete(_statsKey);
    }
  }
}

// Provider
final statsProvider = StateNotifierProvider<StatsNotifier, GameStats>((ref) {
  return StatsNotifier();
});

import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import 'player_model.dart';
import 'challenge_model.dart';

class GameState {
  final String id;
  final GameMode mode;
  final List<Player> players;
  final List<Challenge> usedChallenges;
  int currentPlayerIndex;
  final DateTime startedAt;
  DateTime? endedAt;
  bool isActive;

  GameState({
    String? id,
    required this.mode,
    required this.players,
    List<Challenge>? usedChallenges,
    this.currentPlayerIndex = 0,
    DateTime? startedAt,
    this.endedAt,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4(),
       usedChallenges = usedChallenges ?? [],
       startedAt = startedAt ?? DateTime.now();

  Player get currentPlayer => players[currentPlayerIndex];

  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  void addUsedChallenge(Challenge challenge) {
    usedChallenges.add(challenge);
  }

  void endGame() {
    isActive = false;
    endedAt = DateTime.now();
  }

  Player? get winner {
    if (players.isEmpty) return null;
    return players.reduce((a, b) => a.score > b.score ? a : b);
  }

  List<Player> get leaderboard {
    final sorted = List<Player>.from(players);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mode': mode.name,
    'players': players.map((p) => p.toJson()).toList(),
    'usedChallenges': usedChallenges.map((c) => c.toJson()).toList(),
    'currentPlayerIndex': currentPlayerIndex,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'isActive': isActive,
  };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
    id: json['id'],
    mode: GameMode.values.firstWhere((e) => e.name == json['mode']),
    players: (json['players'] as List).map((p) => Player.fromJson(p)).toList(),
    usedChallenges:
        json['usedChallenges'] != null
            ? (json['usedChallenges'] as List)
                .map((c) => Challenge.fromJson(c))
                .toList()
            : [],
    currentPlayerIndex: json['currentPlayerIndex'] ?? 0,
    startedAt: DateTime.parse(json['startedAt']),
    endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    isActive: json['isActive'] ?? true,
  );
}

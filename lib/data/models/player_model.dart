// import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

// part 'player_model.g.dart';

// @HiveType(typeId: 0)
class Player {
  // @HiveField(0)
  final String id;

  // @HiveField(1)
  String name;

  // @HiveField(2)
  int score;

  // @HiveField(3)
  int truthsCompleted;

  // @HiveField(4)
  int daresCompleted;

  // @HiveField(5)
  int skips;

  // @HiveField(6)
  DateTime createdAt;

  // @HiveField(7)
  String? avatarEmoji;

  Player({
    String? id,
    required this.name,
    this.score = 0,
    this.truthsCompleted = 0,
    this.daresCompleted = 0,
    this.skips = 0,
    DateTime? createdAt,
    this.avatarEmoji,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  void updateScore(int points) {
    score += points;
  }

  void completeTruth() {
    truthsCompleted++;
  }

  void completeDare() {
    daresCompleted++;
  }

  void skip() {
    skips++;
  }

  void reset() {
    score = 0;
    truthsCompleted = 0;
    daresCompleted = 0;
    skips = 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'score': score,
    'truthsCompleted': truthsCompleted,
    'daresCompleted': daresCompleted,
    'skips': skips,
    'createdAt': createdAt.toIso8601String(),
    'avatarEmoji': avatarEmoji,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    score: json['score'] ?? 0,
    truthsCompleted: json['truthsCompleted'] ?? 0,
    daresCompleted: json['daresCompleted'] ?? 0,
    skips: json['skips'] ?? 0,
    createdAt: DateTime.parse(json['createdAt']),
    avatarEmoji: json['avatarEmoji'],
  );
}

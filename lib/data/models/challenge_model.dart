// import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

// part 'challenge_model.g.dart';

// @HiveType(typeId: 1)
class Challenge {
  // @HiveField(0)
  final String id;

  // @HiveField(1)
  final String content;

  // @HiveField(2)
  final ChallengeType type;

  // @HiveField(3)
  final GameMode mode;

  // @HiveField(4)
  final int difficulty; // 1-5 scale

  // @HiveField(5)
  final bool isCustom;

  // @HiveField(6)
  final DateTime createdAt;

  // @HiveField(7)
  final List<String>? tags;

  Challenge({
    String? id,
    required this.content,
    required this.type,
    required this.mode,
    this.difficulty = 3,
    this.isCustom = false,
    DateTime? createdAt,
    this.tags,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'type': type.name,
    'mode': mode.name,
    'difficulty': difficulty,
    'isCustom': isCustom,
    'createdAt': createdAt.toIso8601String(),
    'tags': tags,
  };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json['id'],
    content: json['content'],
    type: ChallengeType.values.firstWhere((e) => e.name == json['type']),
    mode: GameMode.values.firstWhere((e) => e.name == json['mode']),
    difficulty: json['difficulty'] ?? 3,
    isCustom: json['isCustom'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
  );
}

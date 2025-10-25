import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/constants/ad_constants.dart';

// Game session state for managing play limits
class GameSessionState {
  final int remainingGames;
  final bool hasUsedFreeGame;
  final bool isUnlimited;

  GameSessionState({
    required this.remainingGames,
    required this.hasUsedFreeGame,
    this.isUnlimited = false,
  });

  GameSessionState copyWith({
    int? remainingGames,
    bool? hasUsedFreeGame,
    bool? isUnlimited,
  }) {
    return GameSessionState(
      remainingGames: remainingGames ?? this.remainingGames,
      hasUsedFreeGame: hasUsedFreeGame ?? this.hasUsedFreeGame,
      isUnlimited: isUnlimited ?? this.isUnlimited,
    );
  }

  Map<String, dynamic> toJson() => {
    'remainingGames': remainingGames,
    'hasUsedFreeGame': hasUsedFreeGame,
    'isUnlimited': isUnlimited,
  };

  factory GameSessionState.fromJson(Map<String, dynamic> json) {
    return GameSessionState(
      remainingGames: json['remainingGames'] ?? 0,
      hasUsedFreeGame: json['hasUsedFreeGame'] ?? false,
      isUnlimited: json['isUnlimited'] ?? false,
    );
  }
}

class GameSessionNotifier extends StateNotifier<GameSessionState> {
  static const String _boxName = 'gameSession';
  static const String _sessionKey = 'session';
  Box? _box;

  GameSessionNotifier()
    : super(
        GameSessionState(
          remainingGames: 1, // Start with 1 free game
          hasUsedFreeGame: false,
        ),
      ) {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      _box = await Hive.openBox(_boxName);
      _loadSession();
    } catch (e) {
      print('Error initializing game session box: $e');
    }
  }

  void _loadSession() {
    if (_box == null) return;

    final data = _box!.get(_sessionKey);
    if (data != null) {
      state = GameSessionState.fromJson(Map<String, dynamic>.from(data));
    } else {
      // First time user - give them 1 free game
      state = GameSessionState(remainingGames: 1, hasUsedFreeGame: false);
      _saveSession();
    }
  }

  void _saveSession() {
    if (_box == null) {
      print('Session box not initialized, cannot save session');
      return;
    }
    _box!.put(_sessionKey, state.toJson());
  }

  bool get canPlayGame {
    return state.isUnlimited || state.remainingGames > 0;
  }

  void consumeGame() {
    if (!state.isUnlimited && state.remainingGames > 0) {
      state = state.copyWith(
        remainingGames: state.remainingGames - 1,
        hasUsedFreeGame: true, // Mark that the free game has been used
      );
      _saveSession();
    }
  }

  void addRewardedGames() {
    state = state.copyWith(
      remainingGames: state.remainingGames + AdConstants.gamesRewardedByAd,
    );
    _saveSession();
  }

  void enableUnlimitedGames() {
    state = state.copyWith(isUnlimited: true);
    _saveSession();
  }

  void disableUnlimitedGames() {
    state = state.copyWith(isUnlimited: false);
    _saveSession();
  }
}

// Provider
final gameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, GameSessionState>((ref) {
      return GameSessionNotifier();
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GameSettings {
  final bool useBottleMode;
  final bool soundEnabled;
  final bool vibrationsEnabled;
  final bool showTimer;
  final int timerDuration; // in seconds

  const GameSettings({
    this.useBottleMode = true,
    this.soundEnabled = true,
    this.vibrationsEnabled = true,
    this.showTimer = false,
    this.timerDuration = 60,
  });

  GameSettings copyWith({
    bool? useBottleMode,
    bool? soundEnabled,
    bool? vibrationsEnabled,
    bool? showTimer,
    int? timerDuration,
  }) {
    return GameSettings(
      useBottleMode: useBottleMode ?? this.useBottleMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationsEnabled: vibrationsEnabled ?? this.vibrationsEnabled,
      showTimer: showTimer ?? this.showTimer,
      timerDuration: timerDuration ?? this.timerDuration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'useBottleMode': useBottleMode,
      'soundEnabled': soundEnabled,
      'vibrationsEnabled': vibrationsEnabled,
      'showTimer': showTimer,
      'timerDuration': timerDuration,
    };
  }

  factory GameSettings.fromMap(Map<String, dynamic> map) {
    return GameSettings(
      useBottleMode: map['useBottleMode'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationsEnabled: map['vibrationsEnabled'] ?? true,
      showTimer: map['showTimer'] ?? false,
      timerDuration: map['timerDuration'] ?? 60,
    );
  }
}

class SettingsNotifier extends StateNotifier<GameSettings> {
  static const String _boxName = 'settings';
  static const String _settingsKey = 'game_settings';

  SettingsNotifier() : super(const GameSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final box = await Hive.openBox(_boxName);
      final settingsMap = box.get(_settingsKey);
      if (settingsMap != null && settingsMap is Map) {
        state = GameSettings.fromMap(Map<String, dynamic>.from(settingsMap));
      }
    } catch (e) {
      // If error loading settings, use defaults
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_settingsKey, state.toMap());
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  void toggleBottleMode() {
    state = state.copyWith(useBottleMode: !state.useBottleMode);
    _saveSettings();
  }

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    _saveSettings();
  }

  void toggleVibrations() {
    state = state.copyWith(vibrationsEnabled: !state.vibrationsEnabled);
    _saveSettings();
  }

  void toggleTimer() {
    state = state.copyWith(showTimer: !state.showTimer);
    _saveSettings();
  }

  void setTimerDuration(int duration) {
    state = state.copyWith(timerDuration: duration);
    _saveSettings();
  }

  void resetToDefaults() {
    state = const GameSettings();
    _saveSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, GameSettings>((
  ref,
) {
  return SettingsNotifier();
});





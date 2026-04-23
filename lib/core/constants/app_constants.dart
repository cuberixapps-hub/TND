class AppConstants {
  static const String appName = 'Truth or Dare';
  static const String appVersion = '1.0.0';

  // Game Settings
  /// Hard cap (premium). Free tier player limit is defined in `premium_constants.dart` / `premiumProvider`.
  static const int maxPlayers = 20;
  static const int minPlayers = 2;

  // Points System
  static const int truthCompletePoints = 10;
  static const int dareCompletePoints = 15;
  static const int skipPenaltyPoints = -5;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Storage Keys
  static const String playersBoxKey = 'players_box';
  static const String customTruthsBoxKey = 'custom_truths_box';
  static const String customDaresBoxKey = 'custom_dares_box';
  static const String settingsBoxKey = 'settings_box';
  static const String scoresBoxKey = 'scores_box';
}

enum GameMode {
  kids('Kids', '👶', 'Safe and fun for ages 7-12'),
  teens('Teens', '🎉', 'Perfect for ages 13-17'),
  adult('Adult', '🔥', 'Spicy content for 18+'),
  couples('Couples', '💕', 'Romantic and intimate');

  final String label;
  final String emoji;
  final String description;

  const GameMode(this.label, this.emoji, this.description);
}

enum ChallengeType {
  truth('Truth', '🤔'),
  dare('Dare', '😈');

  final String label;
  final String emoji;

  const ChallengeType(this.label, this.emoji);
}

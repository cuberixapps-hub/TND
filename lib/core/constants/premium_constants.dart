/// Premium / freemium limits and paywall cadence.
class PremiumConstants {
  PremiumConstants._();

  static const int freePlayerLimit = 8;
  static const int premiumPlayerLimit = 20;
  static const int freeChallengesPerGatedMode = 3;
  static const int maxAdGamesPerDay = 3;
  static const int postGameUpsellFrequency = 3;

  /// Existing users: days of full access after monetization update.
  static const int migrationGraceDays = 7;

  static const String premiumMetaBoxName = 'premium_meta';
}

import 'package:flutter/foundation.dart';

/// Build-time environment from `--dart-define=ENVIRONMENT=<name>`.
///
/// Run examples:
/// - `flutter run --dart-define=ENVIRONMENT=dev`
/// - `flutter run --release --dart-define=ENVIRONMENT=uat -d <device>`
/// - `flutter build ipa --dart-define=ENVIRONMENT=prod` (App Store)
///
/// If `ENVIRONMENT` is omitted: **debug** builds default to [AppEnvironment.dev];
/// **release/profile** default to [AppEnvironment.prod].
///
/// **AdMob:** Your live ad unit IDs (`ca-app-pub-9565182775442262/...`) are used **only**
/// when [current] is [AppEnvironment.prod]. [AppEnvironment.dev] and [AppEnvironment.uat]
/// always use Google sample units — never production units.
enum AppEnvironment {
  dev,
  uat,
  prod,
}

abstract final class AppEnvironmentConfig {
  static const String _raw = String.fromEnvironment('ENVIRONMENT', defaultValue: '');

  /// Parsed environment for this binary.
  static AppEnvironment get current {
    final key = _raw.trim().toLowerCase();
    if (key.isEmpty) {
      return kDebugMode ? AppEnvironment.dev : AppEnvironment.prod;
    }
    switch (key) {
      case 'dev':
      case 'development':
        return AppEnvironment.dev;
      case 'uat':
      case 'staging':
        return AppEnvironment.uat;
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      default:
        debugPrint(
          '⚠️ Unknown ENVIRONMENT="$_raw". Use dev | uat | prod. Falling back to dev.',
        );
        return AppEnvironment.dev;
    }
  }

  /// Your real AdMob ad unit / app IDs. **Only `ENVIRONMENT=prod`** — never dev or uat.
  static bool get useProductionAdMobUnitIds =>
      current == AppEnvironment.prod;

  /// Google sample ad units (dev + uat, or any non-prod environment).
  static bool get useTestAdMobIds => !useProductionAdMobUnitIds;

  static String get name => current.name;

  static bool get isProd => current == AppEnvironment.prod;
}

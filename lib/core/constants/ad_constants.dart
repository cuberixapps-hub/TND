import 'dart:io';
import 'package:flutter/foundation.dart';

import 'app_environment.dart';

class AdConstants {
  /// Your live publisher ad units. **Only** `ENVIRONMENT=prod` — dev/uat never use these.
  static bool get useProductionAdMobUnitIds =>
      AppEnvironmentConfig.useProductionAdMobUnitIds;

  /// Google sample units (dev, uat, unknown env fallback).
  static bool get useTestAdMobIds => AppEnvironmentConfig.useTestAdMobIds;

  /// Kept for older call sites: unrelated to AdMob ID selection (use [useTestAdMobIds] for ads).
  static bool get isDebugMode => kDebugMode;

  // Production Ad Unit IDs
  static const String _prodBannerAndroid =
      'ca-app-pub-9565182775442262/4766632829';
  static const String _prodBannerIOS = 'ca-app-pub-9565182775442262/2280904435';
  static const String _prodInterstitialAndroid =
      'ca-app-pub-9565182775442262/3414840945';
  static const String _prodInterstitialIOS =
      'ca-app-pub-9565182775442262/2648446389';
  static const String _prodRewardedAndroid =
      'ca-app-pub-9565182775442262/3686303685';
  static const String _prodRewardedIOS =
      'ca-app-pub-9565182775442262/5067668116';

  // Test Ad Unit IDs (Google's test ads)
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _testNativeAndroid =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _testNativeIOS = 'ca-app-pub-3940256099942544/3986624511';

  // App IDs (must match platform manifests where applicable; Dart value is for logging.)
  static String get appId {
    if (Platform.isAndroid) {
      return useProductionAdMobUnitIds
          ? 'ca-app-pub-9565182775442262~1007351216'
          : 'ca-app-pub-3940256099942544~3347511713';
    } else if (Platform.isIOS) {
      return useProductionAdMobUnitIds
          ? 'ca-app-pub-9565182775442262~7717882188'
          : 'ca-app-pub-3940256099942544~1458002511';
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return useProductionAdMobUnitIds
          ? _prodBannerAndroid
          : _testBannerAndroid;
    } else if (Platform.isIOS) {
      return useProductionAdMobUnitIds ? _prodBannerIOS : _testBannerIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return useProductionAdMobUnitIds
          ? _prodInterstitialAndroid
          : _testInterstitialAndroid;
    } else if (Platform.isIOS) {
      return useProductionAdMobUnitIds
          ? _prodInterstitialIOS
          : _testInterstitialIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Rewarded Ad Unit ID
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return useProductionAdMobUnitIds
          ? _prodRewardedAndroid
          : _testRewardedAndroid;
    } else if (Platform.isIOS) {
      return useProductionAdMobUnitIds
          ? _prodRewardedIOS
          : _testRewardedIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Native template: sample units unless [useProductionAdMobUnitIds], then prod banners.
  static String get nativeBannerAdUnitId {
    if (Platform.isAndroid) {
      return useProductionAdMobUnitIds
          ? _prodBannerAndroid
          : _testNativeAndroid;
    } else if (Platform.isIOS) {
      return useProductionAdMobUnitIds ? _prodBannerIOS : _testNativeIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Ad configuration
  static const int maxFailedLoadAttempts = 3;
  static const Duration adLoadTimeout = Duration(seconds: 60);

  // Game play limits
  static const int freeGamesPerDay = 1;
  static const int gamesRewardedByAd = 1; // 1 game per ad per day
}

import 'dart:io';
import 'package:flutter/foundation.dart';

class AdConstants {
  // Determine if we're in debug mode
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

  // App IDs
  static String get appId {
    if (Platform.isAndroid) {
      return isDebugMode
          ? 'ca-app-pub-3940256099942544~3347511713' // Test App ID
          : 'ca-app-pub-9565182775442262~1007351216'; // Production App ID
    } else if (Platform.isIOS) {
      return isDebugMode
          ? 'ca-app-pub-3940256099942544~1458002511' // Test App ID
          : 'ca-app-pub-9565182775442262~7717882188'; // Production App ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return isDebugMode ? _testBannerAndroid : _prodBannerAndroid;
    } else if (Platform.isIOS) {
      return isDebugMode ? _testBannerIOS : _prodBannerIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return isDebugMode ? _testInterstitialAndroid : _prodInterstitialAndroid;
    } else if (Platform.isIOS) {
      return isDebugMode ? _testInterstitialIOS : _prodInterstitialIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Rewarded Ad Unit ID
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return isDebugMode ? _testRewardedAndroid : _prodRewardedAndroid;
    } else if (Platform.isIOS) {
      return isDebugMode ? _testRewardedIOS : _prodRewardedIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Native Banner Ad Unit ID (only test IDs available for now)
  static String get nativeBannerAdUnitId {
    if (Platform.isAndroid) {
      return isDebugMode
          ? _testNativeAndroid
          : _testNativeAndroid; // Using test for production until real IDs provided
    } else if (Platform.isIOS) {
      return isDebugMode
          ? _testNativeIOS
          : _testNativeIOS; // Using test for production until real IDs provided
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

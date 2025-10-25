import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/ad_constants.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Ad instances
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Ad states
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  // Loading states
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  // Retry counts
  int _interstitialLoadAttempts = 0;
  int _rewardedLoadAttempts = 0;

  // Getters
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  // Initialize Mobile Ads SDK
  Future<void> initialize() async {
    await MobileAds.instance.initialize();

    // Log which ad mode is being used
    debugPrint(
      '🎯 AdMob Mode: ${AdConstants.isDebugMode ? "TEST/DEBUG" : "PRODUCTION"}',
    );
    debugPrint('📱 Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
    debugPrint('🆔 App ID: ${AdConstants.appId}');

    // Preload ads
    loadInterstitialAd();
    loadRewardedAd();
  }

  // Interstitial Ad
  void loadInterstitialAd() {
    if (_isInterstitialLoading) return;

    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          _isInterstitialLoading = false;
          _interstitialLoadAttempts = 0;
          debugPrint('Interstitial ad loaded');

          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          _isInterstitialLoading = false;
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          debugPrint('Interstitial ad failed to load: $error');

          if (_interstitialLoadAttempts < AdConstants.maxFailedLoadAttempts) {
            Future.delayed(const Duration(seconds: 2), loadInterstitialAd);
          }
        },
      ),
    );
  }

  // Show Interstitial Ad with loading indicator
  Future<void> showInterstitialAd({
    required BuildContext context,
    VoidCallback? onAdDismissed,
  }) async {
    if (!_isInterstitialAdLoaded) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading ad...'),
                    ],
                  ),
                ),
              ),
            ),
      );

      // Try to load ad
      loadInterstitialAd();

      // Wait for ad to load with timeout
      int attempts = 0;
      while (!_isInterstitialAdLoaded && attempts < 30) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
      }

      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialAdLoaded = false;
          loadInterstitialAd(); // Preload next ad
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialAdLoaded = false;
          loadInterstitialAd();
          onAdDismissed?.call();
        },
      );

      await _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      onAdDismissed?.call();
    }
  }

  // Rewarded Ad
  void loadRewardedAd() {
    if (_isRewardedLoading) return;

    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          _isRewardedLoading = false;
          _rewardedLoadAttempts = 0;
          debugPrint('Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          _isRewardedLoading = false;
          _rewardedLoadAttempts++;
          _rewardedAd = null;
          debugPrint('Rewarded ad failed to load: $error');

          if (_rewardedLoadAttempts < AdConstants.maxFailedLoadAttempts) {
            Future.delayed(const Duration(seconds: 2), loadRewardedAd);
          }
        },
      ),
    );
  }

  // Show Rewarded Ad
  Future<bool> showRewardedAd({
    required BuildContext context,
    VoidCallback? onUserEarnedReward,
  }) async {
    if (!_isRewardedAdLoaded) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading rewarded ad...'),
                    ],
                  ),
                ),
              ),
            ),
      );

      // Try to load ad
      loadRewardedAd();

      // Wait for ad to load with timeout
      int attempts = 0;
      while (!_isRewardedAdLoaded && attempts < 30) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
      }

      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    if (_isRewardedAdLoaded && _rewardedAd != null) {
      final completer = Completer<bool>();

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedAdLoaded = false;
          loadRewardedAd(); // Preload next ad
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isRewardedAdLoaded = false;
          loadRewardedAd();
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onUserEarnedReward?.call();
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
      );

      _rewardedAd = null;
      return completer.future;
    }

    return false;
  }

  // Dispose ads
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}

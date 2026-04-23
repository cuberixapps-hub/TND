import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/premium_constants.dart';
import '../../services/revenue_cat_service.dart';
import 'game_session_provider.dart';

class PremiumState {
  final bool isPremium;
  final bool isLoading;
  final bool paywallShownThisSession;
  final int freeModeChallengesUsed;
  /// Rewarded ads in gated mode grant extra reveals this match.
  final int gatedExtraRevealSlots;
  final int adGamesUsedToday;
  final DateTime? migrationGraceEndsAt;
  final bool debugSimulatePremium;
  /// Until first game-over, skip interstitials for brand-new installs.
  final bool blockInterstitialsUntilFirstGameOver;

  const PremiumState({
    this.isPremium = false,
    this.isLoading = true,
    this.paywallShownThisSession = false,
    this.freeModeChallengesUsed = 0,
    this.gatedExtraRevealSlots = 0,
    this.adGamesUsedToday = 0,
    this.migrationGraceEndsAt,
    this.debugSimulatePremium = false,
    this.blockInterstitialsUntilFirstGameOver = true,
  });

  bool get migrationGraceActive {
    final end = migrationGraceEndsAt;
    if (end == null) return false;
    return DateTime.now().isBefore(end);
  }

  bool get effectivePremium =>
      isPremium ||
      migrationGraceActive ||
      (kDebugMode && debugSimulatePremium);

  bool isModeGated(GameMode mode) {
    if (effectivePremium) return false;
    return mode == GameMode.adult || mode == GameMode.couples;
  }

  bool get hasReachedFreeChallengeLimitInGatedMode =>
      freeModeChallengesUsed >=
      PremiumConstants.freeChallengesPerGatedMode + gatedExtraRevealSlots;

  bool get hasReachedAdGameLimit =>
      adGamesUsedToday >= PremiumConstants.maxAdGamesPerDay;

  int get playerLimit => effectivePremium
      ? PremiumConstants.premiumPlayerLimit
      : PremiumConstants.freePlayerLimit;

  PremiumState copyWith({
    bool? isPremium,
    bool? isLoading,
    bool? paywallShownThisSession,
    int? freeModeChallengesUsed,
    int? gatedExtraRevealSlots,
    int? adGamesUsedToday,
    DateTime? migrationGraceEndsAt,
    bool? debugSimulatePremium,
    bool? blockInterstitialsUntilFirstGameOver,
    bool clearMigrationGrace = false,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      paywallShownThisSession:
          paywallShownThisSession ?? this.paywallShownThisSession,
      freeModeChallengesUsed:
          freeModeChallengesUsed ?? this.freeModeChallengesUsed,
      gatedExtraRevealSlots:
          gatedExtraRevealSlots ?? this.gatedExtraRevealSlots,
      adGamesUsedToday: adGamesUsedToday ?? this.adGamesUsedToday,
      migrationGraceEndsAt: clearMigrationGrace
          ? null
          : (migrationGraceEndsAt ?? this.migrationGraceEndsAt),
      debugSimulatePremium: debugSimulatePremium ?? this.debugSimulatePremium,
      blockInterstitialsUntilFirstGameOver:
          blockInterstitialsUntilFirstGameOver ??
          this.blockInterstitialsUntilFirstGameOver,
    );
  }
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier(this._rcService, this._ref) : super(const PremiumState()) {
    _initialize();
  }

  final RevenueCatService _rcService;
  final Ref _ref;
  Box? _box;

  static const _kMigrationApplied = 'migration_applied';
  static const _kGraceEndsAt = 'grace_ends_at';
  static const _kAdGamesDate = 'ad_games_date';
  static const _kAdGamesCount = 'ad_games_count';
  static const _kDebugSimPremium = 'debug_sim_premium';
  static const _kGamesCompleted = 'games_completed_for_upsell';
  static const _kMigrationBannerShown = 'migration_banner_shown';
  static const _kBlockInterstitial = 'block_interstitial_until_first_game_over';

  Future<void> _initialize() async {
    try {
      _box = await Hive.openBox(PremiumConstants.premiumMetaBoxName);
      await _applyMigrationIfNeeded();
      _loadFromBox();
      _rcService.addCustomerInfoUpdateListener((customerInfo) {
        final isNowPremium =
            customerInfo
                .entitlements
                .all[RevenueCatService.entitlementId]
                ?.isActive ??
            false;
        state = state.copyWith(isPremium: isNowPremium);
        _syncSessionUnlimited();
      });
      final isPremium = await _rcService.isPremium();
      state = state.copyWith(isPremium: isPremium, isLoading: false);
      _syncSessionUnlimited();
    } catch (e) {
      debugPrint('PremiumNotifier init error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _applyMigrationIfNeeded() async {
    final box = _box;
    if (box == null) return;
    if (box.get(_kMigrationApplied) == true) return;

    try {
      final sessionBox = await Hive.openBox('gameSession');
      final data = sessionBox.get('session');
      var hasUsedFreeGame = false;
      if (data != null) {
        final m = Map<String, dynamic>.from(data as Map);
        hasUsedFreeGame = m['hasUsedFreeGame'] == true;
      }

      if (hasUsedFreeGame) {
        final end = DateTime.now().add(
          const Duration(days: PremiumConstants.migrationGraceDays),
        );
        await box.put(_kGraceEndsAt, end.millisecondsSinceEpoch);
        await box.put(_kBlockInterstitial, false);
      }

      await box.put(_kMigrationApplied, true);
    } catch (e) {
      debugPrint('Premium migration error: $e');
      await box.put(_kMigrationApplied, true);
    }
  }

  void _loadFromBox() {
    final box = _box;
    if (box == null) return;

    final graceMs = box.get(_kGraceEndsAt) as int?;
    final debugSim =
        kDebugMode && (box.get(_kDebugSimPremium) == true);
    final adDate = box.get(_kAdGamesDate) as String?;
    final adCount = (box.get(_kAdGamesCount) as int?) ?? 0;
    final today = _todayString();
    final used = adDate == today ? adCount : 0;
    if (adDate != null && adDate != today) {
      box.put(_kAdGamesDate, today);
      box.put(_kAdGamesCount, 0);
    }

    final blockInterstitial =
        (box.get(_kBlockInterstitial) as bool?) ?? true;

    state = state.copyWith(
      migrationGraceEndsAt: graceMs != null
          ? DateTime.fromMillisecondsSinceEpoch(graceMs)
          : null,
      debugSimulatePremium: debugSim,
      adGamesUsedToday: used,
      blockInterstitialsUntilFirstGameOver: blockInterstitial,
    );
  }

  String _todayString() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  void _syncSessionUnlimited() {
    try {
      if (state.effectivePremium) {
        _ref.read(gameSessionProvider.notifier).enableUnlimitedGames();
      } else {
        _ref.read(gameSessionProvider.notifier).disableUnlimitedGames();
      }
    } catch (e) {
      debugPrint('syncSessionUnlimited: $e');
    }
  }

  Future<void> refreshPremiumStatus() async {
    final isPremium = await _rcService.isPremium();
    state = state.copyWith(isPremium: isPremium);
    _syncSessionUnlimited();
  }

  void markPaywallShownThisSession() {
    state = state.copyWith(paywallShownThisSession: true);
  }

  void resetGatedModeChallengeCount() {
    state = state.copyWith(freeModeChallengesUsed: 0, gatedExtraRevealSlots: 0);
  }

  void incrementGatedExtraFromAd() {
    state = state.copyWith(
      gatedExtraRevealSlots: state.gatedExtraRevealSlots + 1,
    );
  }

  void incrementFreeModeChallengesUsed() {
    state = state.copyWith(
      freeModeChallengesUsed: state.freeModeChallengesUsed + 1,
    );
  }

  void incrementAdGamesUsedToday() {
    final box = _box;
    final today = _todayString();
    if (box == null) {
      state = state.copyWith(adGamesUsedToday: state.adGamesUsedToday + 1);
      return;
    }
    var date = box.get(_kAdGamesDate) as String?;
    var count = (box.get(_kAdGamesCount) as int?) ?? 0;
    if (date != today) {
      date = today;
      count = 0;
    }
    count++;
    box.put(_kAdGamesDate, date);
    box.put(_kAdGamesCount, count);
    state = state.copyWith(adGamesUsedToday: count);
  }

  /// Increment completed games (call once per game over).
  void bumpGamesCompletedCount() {
    final box = _box;
    if (box == null) return;
    var n = (box.get(_kGamesCompleted) as int?) ?? 0;
    n++;
    box.put(_kGamesCompleted, n);
    markInterstitialGraceComplete();
  }

  /// Whether this completion count hits the soft upsell cadence.
  bool isPostGameUpsellFrequencyHit() {
    final box = _box;
    if (box == null) return false;
    final n = (box.get(_kGamesCompleted) as int?) ?? 0;
    return n > 0 && n % PremiumConstants.postGameUpsellFrequency == 0;
  }

  void markInterstitialGraceComplete() {
    final box = _box;
    if (box == null) {
      state = state.copyWith(blockInterstitialsUntilFirstGameOver: false);
      return;
    }
    box.put(_kBlockInterstitial, false);
    state = state.copyWith(blockInterstitialsUntilFirstGameOver: false);
  }

  /// One-time banner on home for migrated users in grace period.
  bool consumeMigrationWelcomeBanner() {
    final box = _box;
    if (box == null) return false;
    if (!state.migrationGraceActive) return false;
    if (box.get(_kMigrationBannerShown) == true) return false;
    box.put(_kMigrationBannerShown, true);
    return true;
  }

  Future<void> setDebugSimulatePremium(bool value) async {
    if (!kDebugMode) return;
    final box = _box;
    if (box != null) {
      await box.put(_kDebugSimPremium, value);
    }
    state = state.copyWith(debugSimulatePremium: value);
    _syncSessionUnlimited();
  }
}

final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
      return PremiumNotifier(RevenueCatService(), ref);
    });

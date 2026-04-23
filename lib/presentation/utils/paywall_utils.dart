import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../providers/premium_provider.dart';
import '../screens/paywall_screen.dart';
import '../widgets/paywall_bottom_sheet.dart';

void logPaywallEvent(
  String event, {
  String? offeringId,
  String? action,
}) {
  if (kDebugMode) {
    debugPrint(
      '[paywall_analytics] event=$event offeringId=$offeringId action=$action',
    );
  }
}

/// Full-screen paywall. Returns `true` if purchase completed.
///
/// When [ignorePaywallSessionCap] is false, skips if a paywall was already
/// shown this session (use `true` for settings and mandatory session-limit).
Future<bool> showFullPaywall(
  BuildContext context,
  WidgetRef ref, {
  required String offeringId,
  GameMode? gameMode,
  required String headline,
  String subtitle = '',
  bool showSkipButton = true,
  bool ignorePaywallSessionCap = false,
}) async {
  final ps = ref.read(premiumProvider);
  if (ps.effectivePremium) return false;
  if (!ignorePaywallSessionCap && ps.paywallShownThisSession) {
    return false;
  }

  ref.read(premiumProvider.notifier).markPaywallShownThisSession();
  logPaywallEvent('paywall_view', offeringId: offeringId);

  final result = await Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute<bool>(
      fullscreenDialog: true,
      builder: (ctx) => PaywallScreen(
        offeringId: offeringId,
        gameMode: gameMode,
        headline: headline,
        subtitle: subtitle,
        showSkipButton: showSkipButton,
      ),
    ),
  );
  return result ?? false;
}

/// Bottom-sheet paywall.
/// `true` = purchased, `false` = dismissed after sheet was shown,
/// `null` = not shown (session cap); callers can fall back to ad-only UI.
Future<bool?> showPaywallBottomSheet(
  BuildContext context,
  WidgetRef ref, {
  required String offeringId,
  GameMode? gameMode,
  required String headline,
  bool showWatchAdOption = false,
  Future<bool> Function()? onWatchAd,
  bool ignorePaywallSessionCap = false,
}) async {
  final ps = ref.read(premiumProvider);
  if (ps.effectivePremium) return false;
  if (!ignorePaywallSessionCap && ps.paywallShownThisSession) {
    return null;
  }

  ref.read(premiumProvider.notifier).markPaywallShownThisSession();
  logPaywallEvent('paywall_view', offeringId: offeringId);

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => PaywallBottomSheet(
      offeringId: offeringId,
      gameMode: gameMode,
      headline: headline,
      showWatchAdOption: showWatchAdOption,
      onWatchAd: onWatchAd,
    ),
  );
  return result ?? false;
}

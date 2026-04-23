import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/modern_design_system.dart';
import '../../services/revenue_cat_service.dart';
import '../providers/premium_provider.dart';
import 'paywall_utils.dart';

/// Soft upsell after game over (delayed card). Safe to call from game-over [initState].
void schedulePostGamePremiumUpsell({
  required BuildContext context,
  required WidgetRef ref,
}) {
  Future.delayed(const Duration(seconds: 2), () async {
    if (!context.mounted) return;

    ref.read(premiumProvider.notifier).bumpGamesCompletedCount();

    final st = ref.read(premiumProvider);
    if (st.effectivePremium) return;
    if (st.paywallShownThisSession) return;
    if (!ref.read(premiumProvider.notifier).isPostGameUpsellFrequencyHit()) {
      return;
    }
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black38,
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              ModernDesignSystem.space6,
              0,
              ModernDesignSystem.space6,
              ModernDesignSystem.space8 +
                  MediaQuery.of(ctx).padding.bottom,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusXl),
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(ModernDesignSystem.space5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Want more?',
                      style: ModernDesignSystem.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: ModernDesignSystem.space2),
                    Text(
                      'Go unlimited — all modes, no ads, custom challenges.',
                      style: ModernDesignSystem.bodySmall.copyWith(
                        color: ModernDesignSystem.neutral600,
                      ),
                    ),
                    SizedBox(height: ModernDesignSystem.space4),
                    FilledButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        if (!context.mounted) return;
                        final purchased = await showFullPaywall(
                          context,
                          ref,
                          offeringId: RevenueCatService.offeringPostgame,
                          gameMode: null,
                          headline: 'Go unlimited',
                          subtitle: 'Unlock everything',
                          ignorePaywallSessionCap: false,
                        );
                        if (!context.mounted) return;
                        if (!purchased) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You can upgrade anytime from Settings.',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('See plans'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Maybe later'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/modern_design_system.dart';
import '../../services/revenue_cat_service.dart';
import '../providers/premium_provider.dart';

class PaywallBottomSheet extends ConsumerStatefulWidget {
  const PaywallBottomSheet({
    super.key,
    required this.offeringId,
    required this.gameMode,
    required this.headline,
    this.showWatchAdOption = false,
    this.onWatchAd,
  });

  final String offeringId;
  final GameMode? gameMode;
  final String headline;
  final bool showWatchAdOption;
  final Future<bool> Function()? onWatchAd;

  @override
  ConsumerState<PaywallBottomSheet> createState() =>
      _PaywallBottomSheetState();
}

class _PaywallBottomSheetState extends ConsumerState<PaywallBottomSheet> {
  Offering? _offering;
  bool _loading = true;
  Package? _selected;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final o = await RevenueCatService().getOffering(widget.offeringId);
    if (!mounted) return;
    setState(() {
      _offering = o;
      _loading = false;
      final list = o?.availablePackages ?? [];
      _selected = list.isEmpty
          ? null
          : list.firstWhere(
              (p) => p.packageType == PackageType.annual,
              orElse: () => list.first,
            );
    });
  }

  List<Color> _gradientColors() {
    final m = widget.gameMode;
    if (m == null) {
      return [ModernDesignSystem.primaryColor, ModernDesignSystem.primaryDark];
    }
    switch (m) {
      case GameMode.kids:
        return [ModernDesignSystem.colorKids, ModernDesignSystem.colorTeens];
      case GameMode.teens:
        return [ModernDesignSystem.colorTeens, ModernDesignSystem.primaryDark];
      case GameMode.adult:
        return [ModernDesignSystem.colorAdult, ModernDesignSystem.secondaryDark];
      case GameMode.couples:
        return [ModernDesignSystem.colorCouples, ModernDesignSystem.secondaryColor];
    }
  }

  Future<void> _buy() async {
    final pkg = _selected;
    if (pkg == null || _busy) return;
    setState(() => _busy = true);
    if (kDebugMode) {
      debugPrint(
        '[paywall_analytics] event=paywall_action offeringId=${widget.offeringId} action=purchase_sheet',
      );
    }
    final ok = await RevenueCatService().purchasePackage(pkg);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      await ref.read(premiumProvider.notifier).refreshPremiumStatus();
      if (mounted) Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase did not complete.')),
      );
    }
  }

  Future<void> _restore() async {
    final ok = await RevenueCatService().restorePurchases();
    await ref.read(premiumProvider.notifier).refreshPremiumStatus();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Purchases restored!' : 'No previous purchases found.',
        ),
      ),
    );
    if (ok) Navigator.of(context).pop(true);
  }

  Future<void> _watchAd() async {
    final fn = widget.onWatchAd;
    if (fn == null) return;
    setState(() => _busy = true);
    final ok = await fn();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradientColors();
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    ModernDesignSystem.space6,
                    ModernDesignSystem.space5,
                    ModernDesignSystem.space6,
                    ModernDesignSystem.space6 + bottom,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: ModernDesignSystem.space5),
                    Text(
                      widget.headline,
                      textAlign: TextAlign.center,
                      style: ModernDesignSystem.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: ModernDesignSystem.space4),
                    Wrap(
                      spacing: ModernDesignSystem.space2,
                      runSpacing: ModernDesignSystem.space2,
                      alignment: WrapAlignment.center,
                      children: [
                        _pill('460+ challenges'),
                        _pill('No ads'),
                        _pill('Custom truths & dares'),
                      ],
                    ),
                    SizedBox(height: ModernDesignSystem.space5),
                    if (_offering != null &&
                        _offering!.availablePackages.isNotEmpty)
                      ..._offering!.availablePackages.map((p) {
                        final sel = _selected?.identifier == p.identifier;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: ModernDesignSystem.space2,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() => _selected = p),
                              borderRadius: BorderRadius.circular(
                                ModernDesignSystem.radiusMd,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(ModernDesignSystem.space4),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? Colors.white.withOpacity(0.25)
                                      : Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(
                                    ModernDesignSystem.radiusMd,
                                  ),
                                  border: Border.all(
                                    color: sel ? Colors.white : Colors.white24,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p.storeProduct.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      p.storeProduct.priceString,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    FilledButton(
                      onPressed: _selected != null && !_busy ? _buy : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: colors[0],
                        padding: EdgeInsets.symmetric(
                          vertical: ModernDesignSystem.space4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ModernDesignSystem.radiusLg,
                          ),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Unlock premium',
                              style: ModernDesignSystem.titleSmall.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    if (widget.showWatchAdOption) ...[
                      SizedBox(height: ModernDesignSystem.space3),
                      OutlinedButton(
                        onPressed: _busy ? null : _watchAd,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                          padding: EdgeInsets.symmetric(
                            vertical: ModernDesignSystem.space3,
                          ),
                        ),
                        child: const Text('Watch Ad to Unlock 1 More'),
                      ),
                    ],
                    TextButton(
                      onPressed: _busy ? null : () => Navigator.pop(context, false),
                      child: Text(
                        'Not now',
                        style: TextStyle(color: Colors.white.withOpacity(0.85)),
                      ),
                    ),
                    TextButton(
                      onPressed: _busy ? null : _restore,
                      child: Text(
                        'Restore Purchases',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusFull),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

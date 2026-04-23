import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/modern_design_system.dart';
import '../../services/revenue_cat_service.dart';
import '../providers/premium_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({
    super.key,
    required this.offeringId,
    required this.gameMode,
    required this.headline,
    required this.subtitle,
    this.showSkipButton = true,
  });

  final String offeringId;
  final GameMode? gameMode;
  final String headline;
  final String subtitle;
  final bool showSkipButton;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Offering? _offering;
  bool _loading = true;
  String? _error;
  Package? _selected;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final offering = await RevenueCatService().getOffering(widget.offeringId);
    if (!mounted) return;
    setState(() {
      _offering = offering;
      _loading = false;
      _error = offering == null || offering.availablePackages.isEmpty
          ? 'Unable to load plans. Try again later.'
          : null;
      _selected = _pickDefaultPackage(offering?.availablePackages ?? []);
    });
  }

  Package? _pickDefaultPackage(List<Package> packages) {
    if (packages.isEmpty) return null;
    Package? annual;
    Package? weekly;
    for (final p in packages) {
      if (p.packageType == PackageType.annual) annual = p;
      if (p.packageType == PackageType.weekly) weekly = p;
    }
    return annual ?? weekly ?? packages.first;
  }

  List<Package> _orderedPackages(List<Package> packages) {
    final weekly =
        packages.where((p) => p.packageType == PackageType.weekly).toList();
    final annual =
        packages.where((p) => p.packageType == PackageType.annual).toList();
    final rest = packages
        .where(
          (p) =>
              p.packageType != PackageType.weekly &&
              p.packageType != PackageType.annual,
        )
        .toList();
    return [...weekly, ...annual, ...rest];
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

  Future<void> _purchase() async {
    final pkg = _selected;
    if (pkg == null || _purchasing) return;
    setState(() => _purchasing = true);
    if (kDebugMode) {
      debugPrint(
        '[paywall_analytics] event=paywall_action offeringId=${widget.offeringId} action=purchase',
      );
    }
    final ok = await RevenueCatService().purchasePackage(pkg);
    if (!mounted) return;
    setState(() => _purchasing = false);
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
    if (kDebugMode) {
      debugPrint(
        '[paywall_analytics] event=paywall_action offeringId=${widget.offeringId} action=restore',
      );
    }
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

  void _dismiss() {
    if (kDebugMode) {
      debugPrint(
        '[paywall_analytics] event=paywall_action offeringId=${widget.offeringId} action=dismiss',
      );
    }
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradientColors();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(ModernDesignSystem.space6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: _dismiss,
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                      Text(
                        widget.headline,
                        textAlign: TextAlign.center,
                        style: ModernDesignSystem.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                          height: 1.15,
                        ),
                      ),
                      if (widget.subtitle.isNotEmpty) ...[
                        SizedBox(height: ModernDesignSystem.space3),
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: ModernDesignSystem.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                      SizedBox(height: ModernDesignSystem.space6),
                      _benefit(Icons.all_inclusive, 'Unlimited games'),
                      _benefit(Icons.sports_esports, 'All game modes'),
                      _benefit(Icons.block, 'No ads'),
                      _benefit(Icons.edit_note, 'Custom challenges'),
                      SizedBox(height: ModernDesignSystem.space6),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )
                      else ...[
                        ..._buildPackageCards(),
                        SizedBox(height: ModernDesignSystem.space5),
                        FilledButton(
                          onPressed:
                              _selected != null && !_purchasing ? _purchase : null,
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
                          child: _purchasing
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  'Start 3-Day Free Trial',
                                  style: ModernDesignSystem.titleSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ],
                      if (widget.showSkipButton) ...[
                        SizedBox(height: ModernDesignSystem.space4),
                        TextButton(
                          onPressed: _dismiss,
                          child: Text(
                            'Continue with Ads',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      TextButton(
                        onPressed: _restore,
                        child: Text(
                          'Restore Purchases',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 350.ms).scale(
                      begin: const Offset(0.96, 0.96),
                      curve: Curves.easeOutCubic,
                    ),
        ),
      ),
    );
  }

  Widget _benefit(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ModernDesignSystem.space2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          SizedBox(width: ModernDesignSystem.space3),
          Expanded(
            child: Text(
              text,
              style: ModernDesignSystem.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPackageCards() {
    final packages = _orderedPackages(_offering!.availablePackages);
    return packages.map((p) {
      final isAnnual = p.packageType == PackageType.annual;
      final isWeekly = p.packageType == PackageType.weekly;
      final selected = _selected?.identifier == p.identifier;
      return Padding(
        padding: EdgeInsets.only(bottom: ModernDesignSystem.space3),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _selected = p),
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
            child: Container(
              padding: EdgeInsets.all(ModernDesignSystem.space4),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.28)
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
                border: Border.all(
                  color: selected ? Colors.white : Colors.white24,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isAnnual)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: ModernDesignSystem.colorWarning,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'BEST VALUE',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        Text(
                          isWeekly
                              ? 'Weekly'
                              : isAnnual
                              ? 'Annual'
                              : p.storeProduct.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        if (isAnnual)
                          Text(
                            'SAVE 75%',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    p.storeProduct.priceString,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

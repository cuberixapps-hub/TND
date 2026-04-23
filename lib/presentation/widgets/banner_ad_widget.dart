import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constants/ad_constants.dart';
import '../../core/theme/modern_design_system.dart';
import '../providers/premium_provider.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _adSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  void _loadAd() async {
    if (!mounted) return;

    // Get adaptive ad size for full width
    final width = MediaQuery.of(context).size.width.truncate();
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    if (size == null) {
      debugPrint('Unable to get adaptive banner size');
      return;
    }

    if (!mounted) return;

    setState(() {
      _adSize = size;
    });

    _bannerAd = BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumProvider);
    if (premium.effectivePremium) {
      return const SizedBox.shrink();
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (!_isLoaded || _bannerAd == null || _adSize == null) {
      return Container(
        margin: EdgeInsets.only(
          top: ModernDesignSystem.space4,
          bottom: ModernDesignSystem.space2 + bottomPadding,
        ),
        height:
            _adSize?.height.toDouble() ??
            60, // Reserve space to prevent layout jump
      );
    }

    return Container(
      alignment: Alignment.center,
      width: double.infinity, // Full width
      height: _adSize!.height.toDouble(),
      margin: EdgeInsets.only(
        top: ModernDesignSystem.space4,
        bottom: ModernDesignSystem.space2 + bottomPadding,
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

class NativeBannerAdWidget extends ConsumerStatefulWidget {
  const NativeBannerAdWidget({super.key});

  @override
  ConsumerState<NativeBannerAdWidget> createState() =>
      _NativeBannerAdWidgetState();
}

class _NativeBannerAdWidgetState extends ConsumerState<NativeBannerAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AdConstants.nativeBannerAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native banner ad failed to load: $error');
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: Colors.white,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF4CAF50),
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black87,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black54,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
      ),
    );
    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumProvider);
    if (premium.effectivePremium) {
      return const SizedBox.shrink();
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (!_isLoaded || _nativeAd == null) {
      return Container(
        margin: EdgeInsets.only(
          left: ModernDesignSystem.space4,
          right: ModernDesignSystem.space4,
          top: ModernDesignSystem.space4,
          bottom: ModernDesignSystem.space2 + bottomPadding,
        ),
        height: 100, // Reserve space to prevent layout jump
      );
    }

    return Container(
      height: 100,
      margin: EdgeInsets.only(
        left: ModernDesignSystem.space4,
        right: ModernDesignSystem.space4,
        top: ModernDesignSystem.space4,
        bottom: ModernDesignSystem.space2 + bottomPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
        boxShadow: ModernDesignSystem.elevationLight,
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}

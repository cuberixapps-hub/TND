import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/modern_design_system.dart';
import '../../core/theme/app_icons.dart';
import '../../core/navigation/app_navigation.dart';
import '../../services/revenue_cat_service.dart';
import '../providers/premium_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/paywall_utils.dart';

class ModernSettingsScreen extends ConsumerStatefulWidget {
  const ModernSettingsScreen({super.key});

  @override
  ConsumerState<ModernSettingsScreen> createState() =>
      _ModernSettingsScreenState();
}

class _ModernSettingsScreenState extends ConsumerState<ModernSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernDesignSystem.durationSmooth,
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final premiumState = ref.watch(premiumProvider);

    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundPrimary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernDesignSystem.backgroundPrimary,
              ModernDesignSystem.primaryColor.withOpacity(0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(ModernDesignSystem.space6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPremiumCard(context, premiumState),
                      const SizedBox(height: ModernDesignSystem.space6),
                      ListTile(
                        leading: Icon(
                          Icons.refresh_rounded,
                          color: ModernDesignSystem.primaryColor,
                        ),
                        title: Text(
                          'Restore Purchases',
                          style: ModernDesignSystem.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final restored =
                              await RevenueCatService().restorePurchases();
                          await ref
                              .read(premiumProvider.notifier)
                              .refreshPremiumStatus();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                restored
                                    ? 'Purchases restored!'
                                    : 'No previous purchases found.',
                              ),
                            ),
                          );
                        },
                      ),
                      if (kDebugMode) ...[
                        const SizedBox(height: ModernDesignSystem.space4),
                        SwitchListTile(
                          secondary: Icon(
                            Icons.bug_report_outlined,
                            color: ModernDesignSystem.neutral600,
                          ),
                          title: const Text('Debug: simulate Premium'),
                          value: premiumState.debugSimulatePremium,
                          onChanged: (v) {
                            ref
                                .read(premiumProvider.notifier)
                                .setDebugSimulatePremium(v);
                          },
                        ),
                      ],
                      const SizedBox(height: ModernDesignSystem.space8),
                      // Game Settings
                      _buildSectionTitle('Game Settings'),
                      const SizedBox(height: ModernDesignSystem.space4),
                      _buildGameSettings(settings),

                      const SizedBox(height: ModernDesignSystem.space8),

                      // Experience
                      _buildSectionTitle('Experience'),
                      const SizedBox(height: ModernDesignSystem.space4),
                      _buildExperienceSettings(settings),

                      const SizedBox(height: ModernDesignSystem.space8),

                      // About
                      _buildSectionTitle('About'),
                      const SizedBox(height: ModernDesignSystem.space4),
                      _buildAboutSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ModernDesignSystem.space5),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: ModernDesignSystem.surfaceColor,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
              boxShadow: ModernDesignSystem.elevationLight,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  AppNavigation.pop(context);
                },
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusMd,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(ModernDesignSystem.space3),
                  child: Icon(
                    AppIcons.back,
                    color: ModernDesignSystem.neutral700,
                    size: ModernDesignSystem.iconSizeMd,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: ModernDesignSystem.space4),

          // Title
          Expanded(
            child: Text(
              'Settings',
              style: ModernDesignSystem.headlineMedium.copyWith(
                color: ModernDesignSystem.neutral900,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Save indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ModernDesignSystem.space3,
              vertical: ModernDesignSystem.space2,
            ),
            decoration: BoxDecoration(
              color: ModernDesignSystem.colorSuccess.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                ModernDesignSystem.radiusFull,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.check,
                  size: ModernDesignSystem.iconSizeXs,
                  color: ModernDesignSystem.colorSuccess,
                ),
                const SizedBox(width: ModernDesignSystem.space1),
                Text(
                  'Auto-saved',
                  style: ModernDesignSystem.labelSmall.copyWith(
                    color: ModernDesignSystem.colorSuccess,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildPremiumCard(BuildContext context, PremiumState premiumState) {
    final active = premiumState.effectivePremium;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: active
              ? const [Color(0xFFFFD700), Color(0xFFFFA500)]
              : [
                  ModernDesignSystem.primaryColor,
                  ModernDesignSystem.primaryDark,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
        boxShadow: ModernDesignSystem.elevationMedium,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
        child: InkWell(
          onTap: active
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  showFullPaywall(
                    context,
                    ref,
                    offeringId: RevenueCatService.offeringSettings,
                    gameMode: null,
                    headline: 'Go Premium',
                    subtitle: 'Unlock everything',
                    ignorePaywallSessionCap: true,
                  );
                },
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
          child: Padding(
            padding: EdgeInsets.all(ModernDesignSystem.space5),
            child: Row(
              children: [
                Icon(
                  active ? Icons.diamond_outlined : Icons.lock_open_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: ModernDesignSystem.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        active ? 'Premium Active' : 'Go Premium',
                        style: ModernDesignSystem.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        active
                            ? 'All features unlocked'
                            : 'Unlimited games • No ads • All modes',
                        style: ModernDesignSystem.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!active)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: ModernDesignSystem.titleLarge.copyWith(
        color: ModernDesignSystem.neutral900,
        fontWeight: FontWeight.w700,
      ),
    ).animate().fadeIn().slideX(begin: -0.05, end: 0);
  }

  Widget _buildGameSettings(GameSettings settings) {
    return Column(
      children: [
        _buildToggleTile(
          icon: AppIcons.bottle,
          title: 'Spin the Bottle Mode',
          subtitle: 'Use bottle spinning for player selection',
          value: settings.useBottleMode,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).toggleBottleMode();
          },
          color: ModernDesignSystem.primaryColor,
        ),
        const SizedBox(height: ModernDesignSystem.space3),
        _buildToggleTile(
          icon: AppIcons.timer,
          title: 'Show Timer',
          subtitle: 'Display countdown for challenges',
          value: settings.showTimer,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).toggleTimer();
          },
          color: ModernDesignSystem.colorWarning,
        ),
        if (settings.showTimer) ...[
          const SizedBox(height: ModernDesignSystem.space3),
          _buildSliderTile(
            icon: AppIcons.timer,
            title: 'Timer Duration',
            subtitle: '${settings.timerDuration} seconds',
            value: settings.timerDuration.toDouble(),
            min: 15,
            max: 120,
            divisions: 7,
            onChanged: (value) {
              // TODO: Implement updateTimerDuration in SettingsNotifier
              // ref.read(settingsProvider.notifier)
              //     .updateTimerDuration(value.toInt());
            },
            color: ModernDesignSystem.colorWarning,
          ),
        ],
      ],
    );
  }

  Widget _buildExperienceSettings(GameSettings settings) {
    return Column(
      children: [
        _buildToggleTile(
          icon: AppIcons.sound,
          title: 'Sound Effects',
          subtitle: 'Play sounds during gameplay',
          value: settings.soundEnabled,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            ref.read(settingsProvider.notifier).toggleSound();
          },
          color: ModernDesignSystem.colorInfo,
        ),
        const SizedBox(height: ModernDesignSystem.space3),
        _buildToggleTile(
          icon: AppIcons.vibration,
          title: 'Haptic Feedback',
          subtitle: 'Vibrate on interactions',
          value: settings.vibrationsEnabled,
          onChanged: (value) {
            if (value) {
              HapticFeedback.mediumImpact();
            }
            ref.read(settingsProvider.notifier).toggleVibrations();
          },
          color: ModernDesignSystem.secondaryColor,
        ),
      ],
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return Container(
          decoration: BoxDecoration(
            color: ModernDesignSystem.surfaceColor,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
            boxShadow: ModernDesignSystem.elevationLight,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
            child: InkWell(
              onTap: () => onChanged(!value),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(ModernDesignSystem.space5),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radiusSm,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: color,
                          size: ModernDesignSystem.iconSizeMd,
                        ),
                      ),
                    ),

                    const SizedBox(width: ModernDesignSystem.space4),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: ModernDesignSystem.titleMedium.copyWith(
                              color: ModernDesignSystem.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: ModernDesignSystem.space1),
                          Text(
                            subtitle,
                            style: ModernDesignSystem.bodySmall.copyWith(
                              color: ModernDesignSystem.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Switch
                    _buildModernSwitch(value, onChanged, color),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: ModernDesignSystem.durationQuick)
        .slideX(begin: 0.05, end: 0);
  }

  Widget _buildModernSwitch(
    bool value,
    ValueChanged<bool> onChanged,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: ModernDesignSystem.durationQuick,
        width: 52,
        height: 32,
        decoration: BoxDecoration(
          color: value ? color : ModernDesignSystem.neutral300,
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusFull),
          boxShadow:
              value
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                  : null,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: ModernDesignSystem.durationQuick,
              curve: Curves.easeOut,
              left: value ? 24 : 4,
              top: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required Color color,
  }) {
    return Container(
          decoration: BoxDecoration(
            color: ModernDesignSystem.surfaceColor,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
            boxShadow: ModernDesignSystem.elevationLight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(ModernDesignSystem.space5),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radiusSm,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: color,
                          size: ModernDesignSystem.iconSizeMd,
                        ),
                      ),
                    ),

                    const SizedBox(width: ModernDesignSystem.space4),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: ModernDesignSystem.titleMedium.copyWith(
                              color: ModernDesignSystem.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: ModernDesignSystem.space1),
                          Text(
                            subtitle,
                            style: ModernDesignSystem.bodySmall.copyWith(
                              color: ModernDesignSystem.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: ModernDesignSystem.space4),

                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: color,
                    inactiveTrackColor: color.withOpacity(0.2),
                    thumbColor: color,
                    overlayColor: color.withOpacity(0.1),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: ModernDesignSystem.durationNormal)
        .slideX(begin: 0.05, end: 0);
  }

  // iOS App Store ID - Replace with your actual App Store ID
  static const String _appStoreId = '6738056081';
  // Android Package Name
  static const String _androidPackageName = 'com.cuberix.truthordare';

  Widget _buildAboutSection() {
    return Column(
      children: [
        _buildInfoTile(
          icon: AppIcons.info,
          title: 'Version',
          subtitle: '1.0.2',
          onTap: () {},
        ),
        const SizedBox(height: ModernDesignSystem.space3),
        _buildInfoTile(
          icon: AppIcons.star,
          title: 'Rate Us',
          subtitle: 'Love the app? Let us know!',
          onTap: () => _rateApp(),
        ),
        const SizedBox(height: ModernDesignSystem.space3),
        _buildInfoTile(
          icon: AppIcons.share,
          title: 'Share App',
          subtitle: 'Share with friends',
          onTap: () => _shareApp(),
        ),
      ],
    );
  }

  Future<void> _rateApp() async {
    HapticFeedback.lightImpact();
    
    final InAppReview inAppReview = InAppReview.instance;
    
    try {
      // Check if in-app review is available
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        // Fallback to opening the store directly
        await _openStore();
      }
    } catch (e) {
      debugPrint('Error requesting review: $e');
      // Fallback to opening the store directly
      await _openStore();
    }
  }

  Future<void> _openStore() async {
    Uri storeUrl;
    
    if (Platform.isIOS) {
      storeUrl = Uri.parse('https://apps.apple.com/app/id$_appStoreId');
    } else {
      storeUrl = Uri.parse('https://play.google.com/store/apps/details?id=$_androidPackageName');
    }
    
    try {
      if (await canLaunchUrl(storeUrl)) {
        await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not open store: $e');
    }
  }

  Future<void> _shareApp() async {
    HapticFeedback.lightImpact();
    
    String shareText;
    String storeLink;
    
    if (Platform.isIOS) {
      storeLink = 'https://apps.apple.com/app/id$_appStoreId';
    } else {
      storeLink = 'https://play.google.com/store/apps/details?id=$_androidPackageName';
    }
    
    shareText = '🎉 Check out Truth or Dare: Ultimate Party! '
        'The perfect game for parties and get-togethers.\n\n'
        'Download now: $storeLink';
    
    try {
      await Share.share(
        shareText,
        subject: 'Truth or Dare: Ultimate Party',
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
          decoration: BoxDecoration(
            color: ModernDesignSystem.surfaceColor,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
            boxShadow: ModernDesignSystem.elevationLight,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(ModernDesignSystem.space5),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: ModernDesignSystem.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radiusSm,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: ModernDesignSystem.primaryColor,
                          size: ModernDesignSystem.iconSizeMd,
                        ),
                      ),
                    ),

                    const SizedBox(width: ModernDesignSystem.space4),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: ModernDesignSystem.titleMedium.copyWith(
                              color: ModernDesignSystem.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: ModernDesignSystem.space1),
                          Text(
                            subtitle,
                            style: ModernDesignSystem.bodySmall.copyWith(
                              color: ModernDesignSystem.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Icon(
                      Icons.chevron_right_rounded,
                      color: ModernDesignSystem.neutral400,
                      size: ModernDesignSystem.iconSizeMd,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: ModernDesignSystem.durationSmooth)
        .slideX(begin: 0.05, end: 0);
  }
}

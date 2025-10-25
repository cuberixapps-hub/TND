import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/design_system.dart';
import '../../core/navigation/app_navigation.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/common_widgets.dart';

class SettingsScreenV2 extends ConsumerWidget {
  const SettingsScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return AppScaffold(
      title: 'Settings',
      centerTitle: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: DesignSystem.space6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DesignSystem.space6),

            // Game Settings
            _buildSectionTitle('Game Settings'),
            const SizedBox(height: DesignSystem.space4),

            AppCard(
                  child: Column(
                    children: [
                      _buildToggleTile(
                        icon: Icons.wine_bar_rounded,
                        iconColor: DesignSystem.colorCouples,
                        title: 'Spin the Bottle Mode',
                        subtitle: 'Use bottle spinning to select players',
                        value: settings.useBottleMode,
                        onChanged:
                            () =>
                                ref
                                    .read(settingsProvider.notifier)
                                    .toggleBottleMode(),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.volume_up_rounded,
                        iconColor: DesignSystem.primaryBlue,
                        title: 'Sound Effects',
                        subtitle: 'Play sounds during gameplay',
                        value: settings.soundEnabled,
                        onChanged:
                            () =>
                                ref
                                    .read(settingsProvider.notifier)
                                    .toggleSound(),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.vibration_rounded,
                        iconColor: DesignSystem.colorSuccess,
                        title: 'Haptic Feedback',
                        subtitle: 'Vibrate on interactions',
                        value: settings.vibrationsEnabled,
                        onChanged:
                            () =>
                                ref
                                    .read(settingsProvider.notifier)
                                    .toggleVibrations(),
                      ),
                      _buildDivider(),
                      _buildToggleTile(
                        icon: Icons.timer_outlined,
                        iconColor: DesignSystem.colorWarning,
                        title: 'Challenge Timer',
                        subtitle: 'Set time limits for challenges',
                        value: settings.showTimer,
                        onChanged:
                            () =>
                                ref
                                    .read(settingsProvider.notifier)
                                    .toggleTimer(),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: DesignSystem.durationNormal)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: DesignSystem.space8),

            // Timer Settings (show only if timer is enabled)
            if (settings.showTimer) ...[
              _buildSectionTitle('Timer Settings'),
              const SizedBox(height: DesignSystem.space4),
              AppCard(
                    child: Column(
                      children: [
                        _buildSliderTile(
                          icon: Icons.hourglass_bottom_rounded,
                          iconColor: DesignSystem.colorWarning,
                          title: 'Timer Duration',
                          subtitle: '${settings.timerDuration} seconds',
                          value: settings.timerDuration.toDouble(),
                          min: 30,
                          max: 180,
                          divisions: 15,
                          onChanged:
                              (value) => ref
                                  .read(settingsProvider.notifier)
                                  .setTimerDuration(value.toInt()),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: DesignSystem.durationFast,
                    duration: DesignSystem.durationNormal,
                  )
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: DesignSystem.space8),
            ],

            // Content Settings
            _buildSectionTitle('Content Settings'),
            const SizedBox(height: DesignSystem.space4),

            AppCard(
                  child: Column(
                    children: [
                      _buildActionTile(
                        icon: Icons.add_circle_outline,
                        iconColor: DesignSystem.primaryIndigo,
                        title: 'Custom Challenges',
                        subtitle: 'Create your own challenges',
                        onTap: () {
                          AppNavigation.navigateSlideFromRight(
                            context,
                            Container(), // CustomChallengeManagementScreen
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.filter_list_rounded,
                        iconColor: DesignSystem.colorAdult,
                        title: 'Content Filters',
                        subtitle: 'Control challenge appropriateness',
                        onTap: () => _showComingSoonDialog(context),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(
                  delay: DesignSystem.durationNormal,
                  duration: DesignSystem.durationNormal,
                )
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: DesignSystem.space8),

            // About
            _buildSectionTitle('About'),
            const SizedBox(height: DesignSystem.space4),

            AppCard(
                  child: Column(
                    children: [
                      _buildActionTile(
                        icon: Icons.info_outline,
                        iconColor: DesignSystem.neutral600,
                        title: 'App Version',
                        subtitle: '1.0.0',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: DesignSystem.neutral600,
                        title: 'Privacy Policy',
                        subtitle: 'Learn how we protect your data',
                        onTap: () => _showComingSoonDialog(context),
                      ),
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.description_outlined,
                        iconColor: DesignSystem.neutral600,
                        title: 'Terms of Service',
                        subtitle: 'Read our terms and conditions',
                        onTap: () => _showComingSoonDialog(context),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(
                  delay: DesignSystem.durationSlow,
                  duration: DesignSystem.durationNormal,
                )
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: DesignSystem.space8),

            // Reset button
            Center(
              child: AppButton(
                label: 'Reset to Defaults',
                type: ButtonType.secondary,
                isFullWidth: false,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  AppNavigation.showConfirmation(
                    context: context,
                    title: 'Reset Settings?',
                    message:
                        'This will restore all settings to their default values.',
                    confirmText: 'Reset',
                    confirmColor: DesignSystem.colorError,
                  ).then((confirmed) {
                    if (confirmed) {
                      ref.read(settingsProvider.notifier).resetToDefaults();
                    }
                  });
                },
              ),
            ),

            const SizedBox(height: DesignSystem.space10),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DesignSystem.headlineSmall.copyWith(
        color: DesignSystem.neutral900,
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onChanged,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged();
      },
      borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: DesignSystem.iconSizeMd,
              ),
            ),
            const SizedBox(width: DesignSystem.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignSystem.titleMedium.copyWith(
                      color: DesignSystem.neutral900,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.space1),
                  Text(
                    subtitle,
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DesignSystem.space4),
            _AnimatedToggle(value: value),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.space4),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: DesignSystem.iconSizeMd,
                ),
              ),
              const SizedBox(width: DesignSystem.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: DesignSystem.titleMedium.copyWith(
                        color: DesignSystem.neutral900,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.space1),
                    Text(
                      subtitle,
                      style: DesignSystem.bodySmall.copyWith(
                        color: DesignSystem.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.space4),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: iconColor,
            inactiveColor: iconColor.withOpacity(0.2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.space4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusMd),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: DesignSystem.iconSizeMd,
              ),
            ),
            const SizedBox(width: DesignSystem.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignSystem.titleMedium.copyWith(
                      color: DesignSystem.neutral900,
                    ),
                  ),
                  const SizedBox(height: DesignSystem.space1),
                  Text(
                    subtitle,
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DesignSystem.space4),
            Icon(
              Icons.chevron_right_rounded,
              color: DesignSystem.neutral400,
              size: DesignSystem.iconSizeMd,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: DesignSystem.neutral200);
  }

  void _showComingSoonDialog(BuildContext context) {
    AppNavigation.showAppDialog(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: DesignSystem.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
              ),
              child: const Icon(
                Icons.construction_rounded,
                color: DesignSystem.primaryBlue,
                size: DesignSystem.iconSizeXl,
              ),
            ),
            const SizedBox(height: DesignSystem.space4),
            Text(
              'Coming Soon',
              style: DesignSystem.headlineSmall.copyWith(
                color: DesignSystem.neutral900,
              ),
            ),
            const SizedBox(height: DesignSystem.space2),
            Text(
              'This feature is under development and will be available in a future update.',
              style: DesignSystem.bodyMedium.copyWith(
                color: DesignSystem.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.space6),
            AppButton(
              label: 'Got it',
              onPressed: () => Navigator.pop(context),
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedToggle extends StatelessWidget {
  final bool value;

  const _AnimatedToggle({required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DesignSystem.durationFast,
      width: 52,
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: value ? DesignSystem.colorSuccess : DesignSystem.neutral300,
        borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
      ),
      child: AnimatedAlign(
        duration: DesignSystem.durationFast,
        curve: DesignSystem.curveEaseInOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/design_system.dart';
import '../screens/home_screen.dart';
import '../screens/scoreboard_screen.dart';
import '../screens/custom_challenge_screen.dart';
import '../screens/modern_settings_screen.dart' as modern;

/// Bottom navigation item data
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
}

/// App bottom navigation bar
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<BottomNavItem> items;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.space4,
            vertical: DesignSystem.space2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(context, index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final item = items[index];
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            HapticFeedback.lightImpact();
            onIndexChanged(index);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: DesignSystem.durationFast,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: DesignSystem.durationFast,
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey(isSelected),
                  color:
                      isSelected
                          ? DesignSystem.primaryBlue
                          : DesignSystem.neutral500,
                  size: DesignSystem.iconSizeMd,
                ),
              ),
              const SizedBox(height: DesignSystem.space1),
              Text(
                item.label,
                style: DesignSystem.labelSmall.copyWith(
                  color:
                      isSelected
                          ? DesignSystem.primaryBlue
                          : DesignSystem.neutral500,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main app shell with bottom navigation
class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late List<BottomNavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _navItems = [
      const BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
        page: HomeScreen(),
      ),
      const BottomNavItem(
        icon: Icons.leaderboard_outlined,
        activeIcon: Icons.leaderboard_rounded,
        label: 'Scores',
        page: ScoreboardScreen(),
      ),
      const BottomNavItem(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: 'Create',
        page: CustomChallengeScreen(),
      ),
      const BottomNavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        page: modern.ModernSettingsScreen(),
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onIndexChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: DesignSystem.durationNormal,
      curve: DesignSystem.curveEaseInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _navItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onIndexChanged: _onIndexChanged,
        items: _navItems,
      ),
    );
  }
}

/// Animated navigation indicator
class NavigationIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const NavigationIndicator({
    super.key,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DesignSystem.durationFast,
      width: isActive ? 24 : 0,
      height: 3,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
      ),
    );
  }
}

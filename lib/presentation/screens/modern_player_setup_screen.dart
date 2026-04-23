import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/premium_constants.dart';
import '../../core/theme/modern_design_system.dart';
import '../../core/theme/app_icons.dart';
import '../../core/animations/modern_animations.dart';
import '../../core/navigation/app_navigation.dart';
import '../../data/models/player_model.dart';
import '../../services/revenue_cat_service.dart';
import '../providers/game_session_provider.dart';
import '../providers/players_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/game_provider.dart';
import '../utils/paywall_utils.dart';
import '../widgets/banner_ad_widget.dart';
import '../../services/ad_service.dart';
import 'ultra_modern_game_play_screen.dart';
import 'quirky_home_screen.dart';

class ModernPlayerSetupScreen extends ConsumerStatefulWidget {
  final GameMode mode;

  const ModernPlayerSetupScreen({super.key, required this.mode});

  @override
  ConsumerState<ModernPlayerSetupScreen> createState() =>
      _ModernPlayerSetupScreenState();
}

class _ModernPlayerSetupScreenState
    extends ConsumerState<ModernPlayerSetupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _pulseController;
  bool _isAdding = false;

  // Refined color palette for avatars
  final List<List<Color>> _avatarGradients = [
    [const Color(0xFF667EEA), const Color(0xFF764BA2)],
    [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)],
    [const Color(0xFF4ECDC4), const Color(0xFF2ED573)],
    [const Color(0xFFFFD93D), const Color(0xFFFF9F43)],
    [const Color(0xFFA55EEA), const Color(0xFF6C5CE7)],
    [const Color(0xFF00D9A3), const Color(0xFF00B894)],
    [const Color(0xFFFF6B9D), const Color(0xFFE84393)],
    [const Color(0xFF54A0FF), const Color(0xFF5F27CD)],
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playersProvider.notifier).clearPlayers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isAdding = true);

    final players = ref.read(playersProvider);
    final premiumState = ref.read(premiumProvider);
    if (players.length >= premiumState.playerLimit) {
      if (!premiumState.effectivePremium) {
        _showMessage(
          'Free users can add up to ${premiumState.playerLimit} players. Upgrade to Premium for up to ${PremiumConstants.premiumPlayerLimit}!',
        );
      } else {
        _showMessage('Maximum ${AppConstants.maxPlayers} players allowed');
      }
      setState(() => _isAdding = false);
      return;
    }

    try {
      HapticFeedback.lightImpact();
      ref.read(playersProvider.notifier).addPlayer(name);
      _nameController.clear();
      _focusNode.requestFocus();
    } catch (e) {
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isAdding = false);
    });
  }

  void _removePlayer(String id) {
    HapticFeedback.mediumImpact();
    ref.read(playersProvider.notifier).removePlayer(id);
  }

  void _startGame() async {
    final players = ref.read(playersProvider);

    if (players.length < AppConstants.minPlayers) {
      _showMessage('Minimum ${AppConstants.minPlayers} players required');
      return;
    }

    final premiumState = ref.read(premiumProvider);
    if (premiumState.effectivePremium) {
      _proceedToGame();
      return;
    }

    final sessionState = ref.read(gameSessionProvider);
    if (sessionState.isUnlimited) {
      _proceedToGame();
      return;
    }
    if (sessionState.remainingGames > 0) {
      ref.read(gameSessionProvider.notifier).consumeGame();
      _proceedToGame();
      return;
    }

    if (premiumState.hasReachedAdGameLimit) {
      final purchased = await showFullPaywall(
        context,
        ref,
        offeringId: RevenueCatService.offeringSessionLimit,
        gameMode: widget.mode,
        headline: 'Unlimited Games\nNo Ads, No Limits',
        subtitle: 'You\'ve used all free games today',
        showSkipButton: false,
        ignorePaywallSessionCap: true,
      );
      if (purchased && mounted) {
        _proceedToGame();
      }
      return;
    }

    final purchased = await showFullPaywall(
      context,
      ref,
      offeringId: RevenueCatService.offeringSessionLimit,
      gameMode: widget.mode,
      headline: 'Unlimited Games\nNo Ads, No Limits',
      subtitle: 'Go unlimited or watch a short ad',
      showSkipButton: true,
      ignorePaywallSessionCap: true,
    );

    if (purchased) {
      if (mounted) _proceedToGame();
      return;
    }

    final shouldWatch = await _showWatchAdDialog();
    if (!shouldWatch || !mounted) return;

    final adService = AdService();
    final rewarded = await adService.showRewardedAd(
      context: context,
      isPremium: premiumState.effectivePremium,
      onUserEarnedReward: () {
        ref.read(gameSessionProvider.notifier).addRewardedGames();
        ref.read(premiumProvider.notifier).incrementAdGamesUsedToday();
      },
    );

    if (!mounted) return;

    if (rewarded) {
      _proceedToGame();
    } else {
      _showMessage('Ad not available. Try again later.');
    }
  }

  void _proceedToGame() {
    if (!mounted) return;
    final players = ref.read(playersProvider);
    HapticFeedback.mediumImpact();
    ref.read(premiumProvider.notifier).resetGatedModeChallengeCount();
    ref.read(gameProvider.notifier).startNewGame(widget.mode, players);
    AppNavigation.replaceWithSlide(
      context,
      const UltraModernGamePlayScreen(),
      beginOffset: const Offset(1.0, 0.0),
    );
  }

  Future<bool> _showWatchAdDialog() async {
    final modeGradient = _getModeGradient();
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      modeGradient[0].withOpacity(0.15),
                      modeGradient[1].withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: modeGradient[0],
                  size: 32,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Watch Ad to Play',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 10),

              // Message
              Text(
                'Watch a short video to start your game. It only takes a few seconds!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: const Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: modeGradient),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: modeGradient[0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Watch Ad',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: ModernDesignSystem.neutral800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Color _getModeColor() {
    switch (widget.mode) {
      case GameMode.kids:
        return ModernDesignSystem.colorKids;
      case GameMode.teens:
        return ModernDesignSystem.colorTeens;
      case GameMode.adult:
        return ModernDesignSystem.colorAdult;
      case GameMode.couples:
        return ModernDesignSystem.colorCouples;
    }
  }

  List<Color> _getModeGradient() {
    switch (widget.mode) {
      case GameMode.kids:
        return [const Color(0xFF4ECDC4), const Color(0xFF44B8AD)];
      case GameMode.teens:
        return [const Color(0xFF667EEA), const Color(0xFF5A6FD6)];
      case GameMode.adult:
        return [const Color(0xFFFF6B6B), const Color(0xFFE85A5A)];
      case GameMode.couples:
        return [const Color(0xFFFF4757), const Color(0xFFE8404F)];
    }
  }

  IconData _getModeIcon() {
    switch (widget.mode) {
      case GameMode.kids:
        return AppIcons.kids;
      case GameMode.teens:
        return AppIcons.teens;
      case GameMode.adult:
        return AppIcons.adult;
      case GameMode.couples:
        return AppIcons.couples;
    }
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);
    final modeColor = _getModeColor();
    final modeGradient = _getModeGradient();
    final isReady = players.length >= AppConstants.minPlayers;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final hasKeyboard = keyboardHeight > 0;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Subtle background accent
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.4 + (_pulseController.value * 0.1),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          modeGradient[0].withOpacity(0.15),
                          modeGradient[0].withOpacity(0.02),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: _buildHeader(context, modeColor, modeGradient),
              ),

              // Start button - always at top, fixed position
              Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: _buildStartButton(isReady, modeGradient),
              ),

              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input section
                      _buildInputSection(
                          players.length, modeColor, modeGradient),

                      const SizedBox(height: 20),

                      // Players section
                      if (players.isEmpty)
                        _buildEmptyState(modeGradient)
                      else
                        _buildPlayersList(players),

                      // Extra space for banner ad
                      SizedBox(height: hasKeyboard ? 20 : 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Banner ad at the very bottom (hidden when keyboard is open)
          if (!hasKeyboard)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFFF8FAFC),
                padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 0),
                child: const BannerAdWidget(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, Color modeColor, List<Color> modeGradient) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Back button - refined
          Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(playersProvider.notifier).clearPlayers();
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                              const QuirkyHomeScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                        position: Tween(
                          begin: const Offset(-1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                    AppIcons.back,
                  color: Color(0xFF374151),
                  size: 18,
                ),
              ),
            ),
          ).fadeScaleIn(),

          const SizedBox(width: 14),

          // Title section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Players',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                _buildModeBadge(modeGradient),
              ],
            ).fadeScaleIn(delay: const Duration(milliseconds: 50)),
          ),

          // Mode icon - compact
          Container(
            width: 38,
            height: 38,
                  decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: modeGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: modeGradient[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              _getModeIcon(),
              color: Colors.white,
              size: 18,
            ),
          ).fadeScaleIn(delay: const Duration(milliseconds: 100)),
        ],
      ),
    );
  }

  Widget _buildModeBadge(List<Color> modeGradient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: modeGradient[0].withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${widget.mode.label} Mode',
        style: TextStyle(
          fontSize: 11,
              fontWeight: FontWeight.w600,
          color: modeGradient[0],
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildInputSection(
      int playerCount, Color modeColor, List<Color> modeGradient) {
    return Column(
      children: [
        // Progress card - compact
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: modeGradient[0].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          AppIcons.group,
                          color: modeGradient[0],
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                  Text(
                    'Players',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: modeGradient),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$playerCount/${AppConstants.maxPlayers}',
                      style: const TextStyle(
                        fontSize: 11,
                      fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar - refined
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      widthFactor: playerCount / AppConstants.maxPlayers,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: modeGradient),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).slideUpIn(),

        const SizedBox(height: 14),

        // Input field - refined
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
          children: [
            Expanded(
                child: TextField(
                controller: _nameController,
                focusNode: _focusNode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Player name',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9CA3AF),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: Icon(
                        AppIcons.person,
                        color: const Color(0xFF9CA3AF),
                        size: 18,
                      ),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 42),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                  ),
                textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addPlayer(),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _nameController.text.isNotEmpty
                        ? Padding(
                        padding: const EdgeInsets.only(right: 6),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isAdding ? null : _addPlayer,
                            borderRadius: BorderRadius.circular(10),
                              child: Container(
                              width: 40,
                              height: 40,
                                decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isAdding
                                      ? [
                                          modeGradient[0].withOpacity(0.5),
                                          modeGradient[1].withOpacity(0.5)
                                        ]
                                      : modeGradient,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  AppIcons.add,
                                  color: Colors.white,
                                size: 18,
                                ),
                              ),
                            ),
                          ),
                        )
                    : const SizedBox(width: 46),
              ),
            ],
            ),
        ).slideUpIn(delay: const Duration(milliseconds: 50)),
      ],
    );
  }

  Widget _buildEmptyState(List<Color> modeGradient) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 80,
              height: 80,
            decoration: BoxDecoration(
                color: modeGradient[0].withOpacity(0.08),
              shape: BoxShape.circle,
            ),
              child: Icon(
                AppIcons.group,
                size: 32,
                color: modeGradient[0].withOpacity(0.4),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.03, 1.03),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                )
                .fadeScaleIn(),
            const SizedBox(height: 20),
          Text(
            'No players yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ).fadeScaleIn(delay: const Duration(milliseconds: 50)),
            const SizedBox(height: 6),
          Text(
            'Add at least ${AppConstants.minPlayers} players to start',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9CA3AF),
              ),
            ).fadeScaleIn(delay: const Duration(milliseconds: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersList(List<Player> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            'Players (${players.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
              letterSpacing: 0.3,
            ),
          ),
        ),
        ...players.asMap().entries.map((entry) {
          return _buildPlayerCard(entry.value, entry.key);
        }),
      ],
    );
  }

  Widget _buildPlayerCard(Player player, int index) {
    final gradientColors = _avatarGradients[index % _avatarGradients.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(player.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            AppIcons.delete,
            color: Colors.white,
            size: 18,
          ),
        ),
        onDismissed: (direction) => _removePlayer(player.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar - compact
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    player.name.isNotEmpty
                        ? player.name.substring(0, 1).toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                  player.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Player ${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),

              // Remove button - compact
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _removePlayer(player.id),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                  AppIcons.close,
                      color: Color(0xFF9CA3AF),
                      size: 14,
                ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).staggeredItem(index);
  }

  Widget _buildStartButton(bool isReady, List<Color> modeGradient) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: isReady
            ? LinearGradient(
                colors: modeGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isReady ? null : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isReady
            ? [
                BoxShadow(
                  color: modeGradient[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isReady ? _startGame : null,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.play,
                color: isReady ? Colors.white : const Color(0xFF9CA3AF),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Start Game',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isReady ? Colors.white : const Color(0xFF9CA3AF),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Animated fractional sized box for smooth progress animation
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve,
    required this.widthFactor,
    required this.child,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
    );
  }
}

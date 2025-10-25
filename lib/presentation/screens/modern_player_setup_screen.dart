import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/modern_design_system.dart';
import '../../core/theme/app_icons.dart';
import '../../core/animations/modern_animations.dart';
import '../../core/navigation/app_navigation.dart';
import '../../data/models/player_model.dart';
import '../providers/players_provider.dart';
import '../providers/game_provider.dart';
import '../providers/game_session_provider.dart';
import '../widgets/modern_components.dart';
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
  late AnimationController _listController;
  bool _isAdding = false;

  // Modern color palette for avatars
  final List<Color> _avatarColors = [
    ModernDesignSystem.primaryColor,
    ModernDesignSystem.secondaryColor,
    ModernDesignSystem.colorKids,
    ModernDesignSystem.colorTeens,
    ModernDesignSystem.colorAdult,
    ModernDesignSystem.colorCouples,
    const Color(0xFF4ECDC4),
    const Color(0xFFFFD93D),
  ];

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: ModernDesignSystem.durationSmooth,
      vsync: this,
    );

    // Clear previous players
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playersProvider.notifier).clearPlayers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isAdding = true);

    final players = ref.read(playersProvider);
    if (players.length >= AppConstants.maxPlayers) {
      _showMessage('Maximum ${AppConstants.maxPlayers} players allowed');
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

    Future.delayed(ModernDesignSystem.durationQuick, () {
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

    // Check game session limits
    final gameSession = ref.read(gameSessionProvider.notifier);
    if (!gameSession.canPlayGame) {
      // Show dialog to watch ad
      final shouldWatchAd = await _showWatchAdDialog();
      if (shouldWatchAd) {
        final adService = AdService();

        final rewarded = await adService.showRewardedAd(
          context: context,
          onUserEarnedReward: () {
            gameSession.addRewardedGames();
          },
        );

        if (!rewarded) {
          _showMessage('Failed to load ad. Please try again.');
          return;
        }
      } else {
        return;
      }
    }

    // Consume one game play
    gameSession.consumeGame();

    HapticFeedback.mediumImpact();
    ref.read(gameProvider.notifier).startNewGame(widget.mode, players);

    AppNavigation.replaceWithSlide(
      context,
      const UltraModernGamePlayScreen(),
      beginOffset: const Offset(1.0, 0.0),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernDesignSystem.neutral800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
        ),
      ),
    );
  }

  Future<bool> _showWatchAdDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => Dialog(
                backgroundColor: ModernDesignSystem.surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radius2xl,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(ModernDesignSystem.space6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: ModernDesignSystem.primaryColor.withOpacity(
                            0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.play_circle_outline_rounded,
                            color: ModernDesignSystem.primaryColor,
                            size: 48,
                          ),
                        ),
                      ),

                      const SizedBox(height: ModernDesignSystem.space4),

                      // Title
                      Text(
                        'Free Game Used!',
                        style: ModernDesignSystem.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: ModernDesignSystem.neutral900,
                        ),
                      ),

                      const SizedBox(height: ModernDesignSystem.space3),

                      // Message
                      Text(
                        'No games remaining!',
                        style: ModernDesignSystem.bodyLarge.copyWith(
                          color: ModernDesignSystem.neutral600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: ModernDesignSystem.space2),

                      Text(
                        'Watch a short ad to unlock 1 more game!',
                        style: ModernDesignSystem.bodyMedium.copyWith(
                          color: ModernDesignSystem.neutral700,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: ModernDesignSystem.space1),

                      Text(
                        'You can watch as many ads as you like to keep playing.',
                        style: ModernDesignSystem.labelSmall.copyWith(
                          color: ModernDesignSystem.neutral500,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: ModernDesignSystem.space6),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ModernButton(
                              label: 'Cancel',
                              onPressed: () => Navigator.pop(context, false),
                              isOutlined: true,
                              backgroundColor: ModernDesignSystem.neutral600,
                            ),
                          ),
                          const SizedBox(width: ModernDesignSystem.space3),
                          Expanded(
                            child: ModernButton(
                              label: 'Watch Ad',
                              icon: Icons.play_circle_fill_rounded,
                              onPressed: () => Navigator.pop(context, true),
                              backgroundColor: ModernDesignSystem.successColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ) ??
        false;
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

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);
    final gameSession = ref.watch(gameSessionProvider);
    final modeColor = _getModeColor();
    final isReady = players.length >= AppConstants.minPlayers;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final hasKeyboard = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundPrimary,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    modeColor.withOpacity(0.1),
                    modeColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              // Fixed header
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildHeader(context, modeColor),
                    _buildGameSessionInfo(gameSession, modeColor),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: Stack(
                  children: [
                    // Main content area
                    Positioned.fill(
                      bottom:
                          hasKeyboard
                              ? keyboardHeight
                              : 90 +
                                  MediaQuery.of(context)
                                      .padding
                                      .bottom, // Reserve space for banner ad with safe area
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: ModernDesignSystem.space6,
                          right: ModernDesignSystem.space6,
                          bottom: ModernDesignSystem.space6,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: ModernDesignSystem.space6),

                            // Input section
                            _buildInputSection(players.length, modeColor),

                            const SizedBox(height: ModernDesignSystem.space8),

                            // Players list or empty state
                            players.isEmpty
                                ? SizedBox(
                                  height: 300,
                                  child: _buildEmptyState(),
                                )
                                : Column(
                                  children:
                                      players.asMap().entries.map((entry) {
                                        return _buildPlayerCard(
                                          entry.value,
                                          entry.key,
                                        );
                                      }).toList(),
                                ),

                            const SizedBox(height: ModernDesignSystem.space6),

                            // Start button
                            _buildStartButton(isReady, modeColor),

                            const SizedBox(height: ModernDesignSystem.space6),
                          ],
                        ),
                      ),
                    ),

                    // Banner ad positioned at bottom
                    if (!hasKeyboard)
                      const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: BannerAdWidget(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color modeColor) {
    return Padding(
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
                  ref.read(playersProvider.notifier).clearPlayers();
                  // Navigate back to home screen with a fresh instance
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              const QuirkyHomeScreen(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        const begin = Offset(-1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeOut;

                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
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
          ).fadeScaleIn(),

          const SizedBox(width: ModernDesignSystem.space4),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Players',
                  style: ModernDesignSystem.headlineMedium.copyWith(
                    color: ModernDesignSystem.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: ModernDesignSystem.space1),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ModernDesignSystem.space3,
                    vertical: ModernDesignSystem.space1,
                  ),
                  decoration: BoxDecoration(
                    color: modeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      ModernDesignSystem.radiusFull,
                    ),
                  ),
                  child: Text(
                    '${widget.mode.label} Mode',
                    style: ModernDesignSystem.labelMedium.copyWith(
                      color: modeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ).fadeScaleIn(delay: ModernDesignSystem.durationQuick),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSessionInfo(GameSessionState gameSession, Color modeColor) {
    if (gameSession.isUnlimited || gameSession.remainingGames == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: ModernDesignSystem.space6,
        vertical: ModernDesignSystem.space2,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: ModernDesignSystem.space4,
        vertical: ModernDesignSystem.space3,
      ),
      decoration: BoxDecoration(
        color:
            gameSession.remainingGames <= 1
                ? ModernDesignSystem.warningColor.withOpacity(0.1)
                : ModernDesignSystem.surfaceColor,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMd),
        border: Border.all(
          color:
              gameSession.remainingGames <= 1
                  ? ModernDesignSystem.warningColor.withOpacity(0.3)
                  : ModernDesignSystem.neutral200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            gameSession.remainingGames <= 1
                ? Icons.warning_amber_rounded
                : Icons.videogame_asset_rounded,
            color:
                gameSession.remainingGames <= 1
                    ? ModernDesignSystem.warningColor
                    : modeColor,
            size: 20,
          ),
          const SizedBox(width: ModernDesignSystem.space2),
          Text(
            gameSession.remainingGames == 1 && !gameSession.hasUsedFreeGame
                ? 'Your free game'
                : '${gameSession.remainingGames} games remaining',
            style: ModernDesignSystem.bodyMedium.copyWith(
              color:
                  gameSession.remainingGames <= 1
                      ? ModernDesignSystem.warningColor
                      : ModernDesignSystem.neutral700,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (gameSession.remainingGames <= 1) ...[
            const SizedBox(width: ModernDesignSystem.space2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ModernDesignSystem.space2,
                vertical: ModernDesignSystem.space1,
              ),
              decoration: BoxDecoration(
                color: ModernDesignSystem.successColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusSm,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: ModernDesignSystem.successColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Watch Ad',
                    style: ModernDesignSystem.labelSmall.copyWith(
                      color: ModernDesignSystem.successColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputSection(int playerCount, Color modeColor) {
    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(ModernDesignSystem.space5),
          decoration: BoxDecoration(
            color: ModernDesignSystem.surfaceColor,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
            boxShadow: ModernDesignSystem.elevationLight,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Players',
                    style: ModernDesignSystem.titleMedium.copyWith(
                      color: ModernDesignSystem.neutral700,
                    ),
                  ),
                  Text(
                    '$playerCount / ${AppConstants.maxPlayers}',
                    style: ModernDesignSystem.titleMedium.copyWith(
                      color: modeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ModernDesignSystem.space3),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusFull,
                ),
                child: LinearProgressIndicator(
                  value: playerCount / AppConstants.maxPlayers,
                  backgroundColor: ModernDesignSystem.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(modeColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ).slideUpIn(),

        const SizedBox(height: ModernDesignSystem.space6),

        // Input field
        Row(
          children: [
            Expanded(
              child: ModernTextField(
                label: 'Player name',
                hint: 'Enter player name',
                controller: _nameController,
                focusNode: _focusNode,
                onChanged: (value) => setState(() {}),
                onSubmitted: (_) => _addPlayer(),
                textInputAction: TextInputAction.done,
                suffixIcon:
                    _nameController.text.isNotEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isAdding ? null : _addPlayer,
                              borderRadius: BorderRadius.circular(
                                ModernDesignSystem.radiusSm,
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color:
                                      _isAdding
                                          ? modeColor.withOpacity(0.3)
                                          : modeColor.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(
                                    ModernDesignSystem.radiusSm,
                                  ),
                                ),
                                child: Icon(
                                  AppIcons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        )
                        : null,
              ),
            ),
          ],
        ).slideUpIn(delay: ModernDesignSystem.durationQuick),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: ModernDesignSystem.neutral100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                AppIcons.group,
                size: 60,
                color: ModernDesignSystem.neutral300,
              ),
            ),
          ).fadeScaleIn(),
          const SizedBox(height: ModernDesignSystem.space6),
          Text(
            'No players yet',
            style: ModernDesignSystem.headlineSmall.copyWith(
              color: ModernDesignSystem.neutral700,
            ),
          ).fadeScaleIn(delay: ModernDesignSystem.durationQuick),
          const SizedBox(height: ModernDesignSystem.space2),
          Text(
            'Add at least ${AppConstants.minPlayers} players to start',
            style: ModernDesignSystem.bodyMedium.copyWith(
              color: ModernDesignSystem.neutral500,
            ),
          ).fadeScaleIn(delay: ModernDesignSystem.durationNormal),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Player player, int index) {
    final avatarColor = _avatarColors[index % _avatarColors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: ModernDesignSystem.space3),
      child: Dismissible(
        key: Key(player.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: ModernDesignSystem.space6),
          decoration: BoxDecoration(
            color: ModernDesignSystem.colorError,
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLg),
          ),
          child: Icon(
            AppIcons.delete,
            color: Colors.white,
            size: ModernDesignSystem.iconSizeMd,
          ),
        ),
        onDismissed: (direction) => _removePlayer(player.id),
        child: ModernCard(
          padding: const EdgeInsets.all(ModernDesignSystem.space4),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [avatarColor, avatarColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    player.name.isNotEmpty
                        ? player.name.substring(0, 1).toUpperCase()
                        : '?',
                    style: ModernDesignSystem.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ModernDesignSystem.space4),

              // Name
              Expanded(
                child: Text(
                  player.name,
                  style: ModernDesignSystem.titleMedium.copyWith(
                    color: ModernDesignSystem.neutral900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Remove button
              IconButton(
                icon: Icon(
                  AppIcons.close,
                  color: ModernDesignSystem.neutral400,
                  size: ModernDesignSystem.iconSizeSm,
                ),
                onPressed: () => _removePlayer(player.id),
              ),
            ],
          ),
        ),
      ),
    ).staggeredItem(index);
  }

  Widget _buildStartButton(bool isReady, Color modeColor) {
    return ModernButton(
      label: 'Start Game',
      icon: AppIcons.play,
      onPressed: isReady ? _startGame : null,
      backgroundColor: modeColor,
      size: ButtonSize.large,
      width: double.infinity,
    ).slideUpIn(delay: ModernDesignSystem.durationNormal);
  }
}

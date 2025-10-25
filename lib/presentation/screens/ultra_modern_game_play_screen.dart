import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/app_constants.dart';
import '../../core/theme/modern_design_system.dart';
import '../../core/theme/app_icons.dart';
import '../../core/navigation/app_navigation.dart';
import '../../core/extensions/enum_extensions.dart';
import '../../core/animations/animation_extensions.dart';
import '../../data/models/player_model.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/game_state_model.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/spin_the_bottle_widget_v2.dart';
import '../widgets/banner_ad_widget.dart';
import 'modern_scoreboard_screen.dart';
import 'ultra_modern_game_over_screen.dart';

class UltraModernGamePlayScreen extends ConsumerStatefulWidget {
  const UltraModernGamePlayScreen({super.key});

  @override
  ConsumerState<UltraModernGamePlayScreen> createState() =>
      _UltraModernGamePlayScreenState();
}

class _UltraModernGamePlayScreenState
    extends ConsumerState<UltraModernGamePlayScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _pulseController;

  String? _selectedChoice;
  Challenge? _currentChallenge;
  bool _showChallenge = false;
  bool _isSpinning = false;
  bool _bottleHasSelected = false;
  String? _spinnerName; // Track who spun the bottle
  int? _selectedPlayerIndex; // Track the selected player index

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: ModernDesignSystem.durationSmooth,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cardController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTruthOrDare(String choice) {
    setState(() {
      _selectedChoice = choice;
    });

    HapticFeedback.mediumImpact();

    // Get challenge
    final gameState = ref.read(gameProvider);
    if (gameState == null) return;

    final challenge = ref
        .read(gameProvider.notifier)
        .getRandomChallenge(
          choice == 'Truth' ? ChallengeType.truth : ChallengeType.dare,
        );

    setState(() {
      _currentChallenge = challenge;
      _showChallenge = true;
    });

    _cardController.forward();
  }

  void _completeChallenge(bool completed) {
    HapticFeedback.lightImpact();

    final settings = ref.read(settingsProvider);

    if (_currentChallenge != null) {
      if (settings.useBottleMode) {
        // In bottle mode, use methods that don't advance turn
        if (completed) {
          ref
              .read(gameProvider.notifier)
              .completeChallengeBottleMode(_currentChallenge!.type);
        } else {
          ref.read(gameProvider.notifier).skipChallengeBottleMode();
        }
        print(
          'Bottle mode: Same player (${ref.read(gameProvider)?.currentPlayer.name}) will spin again',
        );
      } else {
        // In normal mode, use regular methods that advance turn
        if (completed) {
          ref
              .read(gameProvider.notifier)
              .completeChallenge(_currentChallenge!.type);
        } else {
          ref.read(gameProvider.notifier).skipChallenge();
        }
      }
    }

    setState(() {
      _showChallenge = false;
      _selectedChoice = null;
      _currentChallenge = null;
      _bottleHasSelected = false;
      if (!settings.useBottleMode) {
        _spinnerName = null; // Reset spinner name in normal mode
        _selectedPlayerIndex = null; // Reset selected player in normal mode
      }
      // In bottle mode, keep spinner name and selected player as it's the same player spinning again
    });

    _cardController.reverse();

    final gameState = ref.read(gameProvider);
    if (gameState != null && !gameState.isActive) {
      Future.delayed(const Duration(milliseconds: 500), () {
        AppNavigation.replaceWithSlide(
          context,
          const UltraModernGameOverScreen(),
        );
      });
    }
  }

  void _showScoreboard() {
    HapticFeedback.lightImpact();
    AppNavigation.navigateSlideFromBottom(
      context,
      const ModernScoreboardScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);

    if (gameState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentPlayer = gameState.currentPlayer;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundPrimary,
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(size, gameState),

          // Floating particles
          ..._buildFloatingParticles(size),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Modern header
                _buildHeader(gameState),

                // Game content
                Expanded(
                  child:
                      settings.useBottleMode &&
                              !_bottleHasSelected &&
                              !_showChallenge
                          ? _buildBottleMode(gameState)
                          : _buildNormalMode(
                            gameState,
                            // Use selected player if available, otherwise current player
                            _selectedPlayerIndex != null &&
                                    settings.useBottleMode
                                ? gameState.players[_selectedPlayerIndex!]
                                : currentPlayer,
                          ),
                ),

                // Banner Ad at bottom
                const BannerAdWidget(),
              ],
            ),
          ),

          // End game button
          Positioned(
            bottom: 110 + MediaQuery.of(context).padding.bottom,
            right: 20,
            child: _buildEndGameButton(),
          ),
        ],
      ),
    );
  }

  Color _getModeColor(GameMode mode) {
    switch (mode) {
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

  int _calculateRound(GameState gameState) {
    // Calculate round based on total completed challenges
    int totalChallenges = 0;
    for (var player in gameState.players) {
      totalChallenges +=
          player.truthsCompleted + player.daresCompleted + player.skips;
    }
    return (totalChallenges ~/ gameState.players.length) + 1;
  }

  Widget _buildAnimatedBackground(Size size, GameState gameState) {
    final modeColor = _getModeColor(gameState.mode);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            modeColor.withOpacity(0.1),
            ModernDesignSystem.backgroundPrimary,
            modeColor.withOpacity(0.05),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingParticles(Size size) {
    return [];
  }

  Widget _buildHeader(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(ModernDesignSystem.space5),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: ModernDesignSystem.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: ModernDesignSystem.elevationLight,
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => _showEndGameDialog(),
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
              ),
            ),
          ),

          const SizedBox(width: ModernDesignSystem.space4),

          // Game info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${gameState.mode.enumName} Mode',
                  style: ModernDesignSystem.bodyLarge.copyWith(
                    color: ModernDesignSystem.neutral600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Round ${_calculateRound(gameState)}',
                  style: ModernDesignSystem.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Scoreboard button
          Container(
            decoration: BoxDecoration(
              color: ModernDesignSystem.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _showScoreboard,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    AppIcons.leaderboard,
                    size: 20,
                    color: ModernDesignSystem.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).slideDownIn();
  }

  Widget _buildBottleMode(GameState gameState) {
    // If showing challenge, show the challenge view instead
    if (_showChallenge && _currentChallenge != null) {
      return _buildChallengeView();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Instruction text
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: ModernDesignSystem.space6,
                      vertical: ModernDesignSystem.space4,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isSpinning
                              ? 'Spinning...'
                              : '${_selectedPlayerIndex != null ? gameState.players[_selectedPlayerIndex!].name : gameState.currentPlayer.name}, spin the bottle!',
                          style: ModernDesignSystem.headlineMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: ModernDesignSystem.neutral900,
                          ),
                          textAlign: TextAlign.center,
                        ).slideUpIn(),
                        if (!_isSpinning)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'The selected player will choose Truth or Dare',
                              style: ModernDesignSystem.bodyMedium.copyWith(
                                color: ModernDesignSystem.neutral600,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 200.ms),
                          ),
                      ],
                    ),
                  ),

                  // Bottle widget
                  Expanded(
                    child: SpinTheBottleWidgetV2(
                      players: gameState.players,
                      currentPlayerIndex:
                          _selectedPlayerIndex ?? gameState.currentPlayerIndex,
                      onSpinStart: () {
                        print('Spin started - updating state');
                        setState(() {
                          _isSpinning = true;
                          // We're in bottle mode, so use selected player if available
                          if (_selectedPlayerIndex != null) {
                            _spinnerName =
                                gameState.players[_selectedPlayerIndex!].name;
                          } else {
                            _spinnerName = gameState.currentPlayer.name;
                          }
                          print('Spinner is: $_spinnerName');
                        });
                      },
                      onPlayerSelected: (selectedIndex) {
                        print('Player selected: $selectedIndex');
                        print('Spinner was: $_spinnerName');
                        print(
                          'Selected player: ${gameState.players[selectedIndex].name}',
                          );

                          // Store the selected player index first
                          setState(() {
                            _isSpinning = false;
                            _bottleHasSelected = true;
                            _selectedPlayerIndex = selectedIndex;
                          });

                          // Update current player in game state
                          ref
                              .read(gameProvider.notifier)
                              .setCurrentPlayer(selectedIndex);
                        },
                        modeColor: _getModeColor(gameState.mode),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
    );
  }

  Widget _buildNormalMode(GameState gameState, Player currentPlayer) {
    if (_showChallenge && _currentChallenge != null) {
      return _buildChallengeView();
    }

    final settings = ref.read(settingsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(ModernDesignSystem.space6),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  constraints.maxHeight - (ModernDesignSystem.space6 * 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Player avatar with pulse
                _buildPlayerAvatar(currentPlayer),

                const SizedBox(height: ModernDesignSystem.space8),

                // Player name
                Text(
                  currentPlayer.name,
                  style: ModernDesignSystem.displaySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ModernDesignSystem.neutral900,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ).slideUpIn(),

                const SizedBox(height: ModernDesignSystem.space3),

                // Choose text with bottle info
                Column(
                  children: [
                    Text(
                      'Choose your challenge',
                      style: ModernDesignSystem.headlineSmall.copyWith(
                        color: ModernDesignSystem.neutral600,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),
                    if (settings.useBottleMode &&
                        _spinnerName != null &&
                        _spinnerName != currentPlayer.name)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Selected by ${_spinnerName}\'s spin',
                          style: ModernDesignSystem.bodyMedium.copyWith(
                            color: ModernDesignSystem.neutral500,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 300.ms),
                      ),
                  ],
                ),

                const SizedBox(height: ModernDesignSystem.space8),

                // Truth or Dare buttons
                _buildChoiceButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerAvatar(Player player) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + 0.05 * math.sin(_pulseController.value * 2 * math.pi),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ModernDesignSystem.primaryColor,
                  ModernDesignSystem.secondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: ModernDesignSystem.primaryColor.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                style: ModernDesignSystem.displayLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      },
    ).animate().scale(duration: ModernDesignSystem.durationSmooth);
  }

  Widget _buildChoiceButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChoiceButton(
          'Truth',
          '🤔',
          ModernDesignSystem.primaryColor,
          Icons.psychology_rounded,
          0,
        ),
        const SizedBox(width: ModernDesignSystem.space5),
        _buildChoiceButton(
          'Dare',
          '🔥',
          ModernDesignSystem.secondaryColor,
          Icons.bolt_rounded,
          1,
        ),
      ],
    );
  }

  Widget _buildChoiceButton(
    String label,
    String emoji,
    Color color,
    IconData icon,
    int index,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius3xl),
      child: InkWell(
        onTap: () => _handleTruthOrDare(label),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radius3xl),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Container(
              width: 140,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radius3xl,
                ),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background decoration
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji
                        Text(emoji, style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: ModernDesignSystem.space2),
                        // Icon with glow effect
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const SizedBox(height: ModernDesignSystem.space3),
                        // Label
                        Text(
                          label,
                          style: ModernDesignSystem.headlineSmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Shimmer effect overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radius3xl,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 300 + index * 100))
            .slideY(
              begin: 0.2,
              end: 0,
              delay: Duration(milliseconds: 300 + index * 100),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            )
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              delay: Duration(milliseconds: 300 + index * 100),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }

  Widget _buildChallengeView() {
    final gameState = ref.read(gameProvider);
    if (gameState == null || _currentChallenge == null) return Container();

    final settings = ref.read(settingsProvider);

    // Get the correct player - either selected player in bottle mode or current player
    final challengePlayer =
        (_selectedPlayerIndex != null && settings.useBottleMode)
            ? gameState.players[_selectedPlayerIndex!]
            : gameState.currentPlayer;

    Color challengeColor =
        _selectedChoice == 'Truth'
            ? ModernDesignSystem.primaryColor
            : ModernDesignSystem.secondaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: ModernDesignSystem.space5,
            vertical: ModernDesignSystem.space6,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  constraints.maxHeight - (ModernDesignSystem.space6 * 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Challenge type badge - minimal and elegant
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ModernDesignSystem.space4,
                    vertical: ModernDesignSystem.space2,
                  ),
                  decoration: BoxDecoration(
                    color: challengeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      ModernDesignSystem.radiusFull,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedChoice == 'Truth'
                            ? Icons.lightbulb_outline_rounded
                            : Icons.flash_on_rounded,
                        color: challengeColor,
                        size: 18,
                      ),
                      const SizedBox(width: ModernDesignSystem.space2),
                      Text(
                        _selectedChoice ?? '',
                        style: ModernDesignSystem.bodyLarge.copyWith(
                          color: challengeColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut),

                const SizedBox(height: ModernDesignSystem.space6),

                // Main challenge card - clean and minimal
                Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: ModernDesignSystem.surfaceColor,
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radius2xl,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header section
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ModernDesignSystem.space6,
                              vertical: ModernDesignSystem.space5,
                            ),
                            child: Column(
                              children: [
                                // Player name - subtle
                                Text(
                                  challengePlayer.name,
                                  style: ModernDesignSystem.bodyLarge.copyWith(
                                    color: ModernDesignSystem.neutral500,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(
                                  height: ModernDesignSystem.space4,
                                ),
                                // Challenge text - clear hierarchy
                                Text(
                                  _currentChallenge!.content,
                                  style: ModernDesignSystem.headlineSmall
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                        color: ModernDesignSystem.neutral900,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 8,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                          ),

                          // Divider
                          Container(
                            height: 1,
                            color: ModernDesignSystem.neutral200.withOpacity(
                              0.5,
                            ),
                          ),

                          // Points section - minimal
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ModernDesignSystem.space6,
                              vertical: ModernDesignSystem.space4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star_outline_rounded,
                                  color: challengeColor,
                                  size: 18,
                                ),
                                const SizedBox(
                                  width: ModernDesignSystem.space2,
                                ),
                                Text(
                                  '${_currentChallenge!.difficulty} points',
                                  style: ModernDesignSystem.bodyMedium.copyWith(
                                    color: challengeColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .slideY(
                      begin: 0.02,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: ModernDesignSystem.space8),

                // Action buttons - clean and modern
                Row(
                  children: [
                    // Skip button - minimal outline
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radiusFull,
                        ),
                        child: InkWell(
                          onTap: () => _completeChallenge(false),
                          borderRadius: BorderRadius.circular(
                            ModernDesignSystem.radiusFull,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ModernDesignSystem.neutral300,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(
                                ModernDesignSystem.radiusFull,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Skip',
                                style: ModernDesignSystem.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ModernDesignSystem.neutral600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: ModernDesignSystem.space3),

                    // Done button - solid with subtle shadow
                    Expanded(
                      child: Material(
                        color: challengeColor,
                        borderRadius: BorderRadius.circular(
                          ModernDesignSystem.radiusFull,
                        ),
                        elevation: 0,
                        child: InkWell(
                          onTap: () => _completeChallenge(true),
                          borderRadius: BorderRadius.circular(
                            ModernDesignSystem.radiusFull,
                          ),
                          splashColor: Colors.white.withOpacity(0.2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                ModernDesignSystem.radiusFull,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: challengeColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Done',
                                style: ModernDesignSystem.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(
                  delay: 500.ms,
                  duration: 300.ms,
                  curve: Curves.easeOut,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEndGameButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: ModernDesignSystem.shadowMedium,
      ),
      child: Material(
        color: ModernDesignSystem.errorColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _showEndGameDialog,
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(ModernDesignSystem.space4),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: const Duration(seconds: 1));
  }

  void _showEndGameDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.85),
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                    constraints: const BoxConstraints(maxWidth: 380),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ModernDesignSystem.surfaceColor,
                          ModernDesignSystem.surfaceColor.withOpacity(0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: ModernDesignSystem.errorColor.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ModernDesignSystem.errorColor.withOpacity(0.1),
                          blurRadius: 48,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon with animation
                              TweenAnimationBuilder<double>(
                                duration: const Duration(seconds: 2),
                                tween: Tween(begin: 0, end: 1),
                                builder: (context, value, child) {
                                  return Transform.rotate(
                                    angle: math.sin(value * math.pi * 2) * 0.1,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            ModernDesignSystem.warningColor
                                                .withOpacity(0.2),
                                            ModernDesignSystem.warningColor
                                                .withOpacity(0.1),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: ModernDesignSystem
                                                .warningColor
                                                .withOpacity(0.3),
                                            blurRadius: 32,
                                            spreadRadius: -8,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.priority_high_rounded,
                                          color:
                                              ModernDesignSystem.warningColor,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // Title with gradient
                              ShaderMask(
                                shaderCallback:
                                    (bounds) => LinearGradient(
                                      colors: [
                                        ModernDesignSystem.neutral900,
                                        ModernDesignSystem.neutral700,
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  'End Game?',
                                  style: ModernDesignSystem.headlineMedium
                                      .copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Subtitle
                              Text(
                                'Are you sure you want to end the current game?',
                                style: ModernDesignSystem.bodyLarge.copyWith(
                                  color: ModernDesignSystem.neutral600,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 32),

                              // Buttons
                              Row(
                                children: [
                                  // Cancel button
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          Navigator.pop(context);
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color:
                                                ModernDesignSystem.neutral100,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color:
                                                  ModernDesignSystem.neutral200,
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Cancel',
                                              style: ModernDesignSystem
                                                  .titleMedium
                                                  .copyWith(
                                                    color:
                                                        ModernDesignSystem
                                                            .neutral700,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // End Game button
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          HapticFeedback.mediumImpact();
                                          Navigator.pop(context);
                                          ref
                                              .read(gameProvider.notifier)
                                              .endGame();

                                          AppNavigation.replaceWithSlide(
                                            context,
                                            const UltraModernGameOverScreen(),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                ModernDesignSystem.errorColor,
                                                ModernDesignSystem.errorColor
                                                    .withOpacity(0.8),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: ModernDesignSystem
                                                    .errorColor
                                                    .withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              'End Game',
                                              style: ModernDesignSystem
                                                  .titleMedium
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ),
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
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 200.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
          ),
    );
  }
}

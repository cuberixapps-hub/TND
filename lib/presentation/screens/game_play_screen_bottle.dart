import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/navigation/app_navigation.dart';
import '../../core/theme/design_system.dart';
import '../../data/models/challenge_model.dart';
import '../providers/game_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/common_widgets.dart';
import '../widgets/spin_the_bottle_widget.dart';
import '../widgets/animated_card.dart';
import 'scoreboard_screen.dart';
import 'game_over_screen.dart';

class GamePlayScreenBottle extends ConsumerStatefulWidget {
  const GamePlayScreenBottle({super.key});

  @override
  ConsumerState<GamePlayScreenBottle> createState() =>
      _GamePlayScreenBottleState();
}

class _GamePlayScreenBottleState extends ConsumerState<GamePlayScreenBottle>
    with TickerProviderStateMixin {
  // Game state
  ChallengeType? _selectedType;
  Challenge? _currentChallenge;
  bool _showChallenge = false;
  bool _waitingForSpin = true;

  // Animation controllers
  late AnimationController _challengeController;
  late AnimationController _fadeController;
  late Animation<double> _challengeAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _challengeController = AnimationController(
      duration: DesignSystem.durationSlow,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: DesignSystem.durationNormal,
      vsync: this,
    );

    _challengeAnimation = CurvedAnimation(
      parent: _challengeController,
      curve: DesignSystem.curveEaseOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: DesignSystem.curveEaseInOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _challengeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Color _getModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'kids':
        return DesignSystem.colorKids;
      case 'teens':
        return DesignSystem.colorTeens;
      case 'adult':
        return DesignSystem.colorAdult;
      case 'couples':
        return DesignSystem.colorCouples;
      default:
        return DesignSystem.primaryBlue;
    }
  }

  void _onPlayerSelected(int playerIndex) {
    final gameState = ref.read(gameProvider);
    if (gameState == null) return;

    // Update current player
    ref.read(gameProvider.notifier).setCurrentPlayer(playerIndex);

    setState(() {
      _waitingForSpin = false;
      _showChallenge = false;
      _selectedType = null;
      _currentChallenge = null;
    });

    // Show selection animation
    HapticFeedback.mediumImpact();
  }

  void _selectChallengeType(ChallengeType type) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedType = type;
    });

    Future.delayed(DesignSystem.durationFast, () {
      if (mounted) {
        final challenge = ref
            .read(gameProvider.notifier)
            .getRandomChallenge(type);
        setState(() {
          _currentChallenge = challenge;
          _showChallenge = true;
        });
        _challengeController.forward(from: 0);
      }
    });
  }

  void _completeChallenge() {
    if (_selectedType != null) {
      HapticFeedback.mediumImpact();
      ref.read(gameProvider.notifier).completeChallenge(_selectedType!);
      _resetForNextTurn();
    }
  }

  void _skipChallenge() {
    HapticFeedback.lightImpact();
    ref.read(gameProvider.notifier).skipChallenge();
    _resetForNextTurn();
  }

  void _resetForNextTurn() {
    setState(() {
      _selectedType = null;
      _currentChallenge = null;
      _showChallenge = false;
      _waitingForSpin = true;
    });
    _challengeController.reset();
  }

  void _showScoreboard() {
    HapticFeedback.lightImpact();
    AppNavigation.navigateSlideFromBottom(context, const ScoreboardScreen());
  }

  void _showEndGameDialog() {
    HapticFeedback.mediumImpact();
    AppNavigation.showConfirmation(
      context: context,
      title: 'End Game?',
      message: 'Are you sure you want to end this game?',
      confirmText: 'End Game',
      cancelText: 'Continue',
      confirmColor: DesignSystem.colorError,
    ).then((confirmed) {
      if (confirmed) {
        ref.read(gameProvider.notifier).endGame();
        AppNavigation.replaceWithSlide(context, const GameOverScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    if (gameState == null) {
      return const Scaffold(body: Center(child: AppLoadingIndicator()));
    }

    final currentPlayer = gameState.currentPlayer;
    final modeColor = _getModeColor(gameState.mode.name);

    return AppScaffold(
      title: 'Truth or Dare',
      showBackButton: false,
      actions: [
        AppIconButton(
          icon: Icons.leaderboard_outlined,
          onPressed: _showScoreboard,
          size: DesignSystem.iconSizeSm,
        ),
        const SizedBox(width: DesignSystem.space2),
        AppIconButton(
          icon: Icons.close_rounded,
          onPressed: _showEndGameDialog,
          size: DesignSystem.iconSizeSm,
          color: DesignSystem.colorError,
        ),
      ],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Game mode indicator
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: DesignSystem.space6,
                vertical: DesignSystem.space2,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.space4,
                vertical: DesignSystem.space2,
              ),
              decoration: BoxDecoration(
                color: modeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
              ),
              child: Text(
                '${gameState.mode.label} Mode',
                style: DesignSystem.labelMedium.copyWith(
                  color: modeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Expanded(
              child: AnimatedSwitcher(
                duration: DesignSystem.durationNormal,
                child:
                    _waitingForSpin
                        ? _buildSpinView(gameState, modeColor)
                        : _showChallenge
                        ? _buildChallengeView(currentPlayer, modeColor)
                        : _buildSelectionView(currentPlayer, modeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinView(gameState, Color modeColor) {
    return Column(
      children: [
        const SizedBox(height: DesignSystem.space8),

        // Instructions
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: DesignSystem.space6),
          child: Column(
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: DesignSystem.iconSizeXl,
                color: modeColor,
              ),
              const SizedBox(height: DesignSystem.space3),
              Text(
                'Spin the Bottle!',
                style: DesignSystem.headlineSmall.copyWith(
                  color: DesignSystem.neutral900,
                ),
              ),
              const SizedBox(height: DesignSystem.space2),
              Text(
                '${gameState.currentPlayer.name}, spin to select the next player',
                style: DesignSystem.bodyMedium.copyWith(
                  color: DesignSystem.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: DesignSystem.space8),

        // Spin the bottle widget
        Expanded(
          child: Center(
            child: SpinTheBottleWidget(
              players: gameState.players,
              currentPlayerIndex: gameState.currentPlayerIndex,
              onSpinStart: () {
                // Handle spin start if needed
              },
              onPlayerSelected: _onPlayerSelected,
              modeColor: modeColor,
            ),
          ),
        ),

        const SizedBox(height: DesignSystem.space8),
      ],
    );
  }

  Widget _buildSelectionView(player, Color modeColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Selected player announcement
        AnimatedCard(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.space6,
                ),
                padding: const EdgeInsets.all(DesignSystem.space6),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: modeColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: DesignSystem.iconSizeXl,
                        color: modeColor,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.space4),
                    Text(
                      player.name,
                      style: DesignSystem.headlineMedium.copyWith(
                        color: DesignSystem.neutral900,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.space2),
                    Text(
                      'The bottle chose you!',
                      style: DesignSystem.bodyLarge.copyWith(
                        color: DesignSystem.neutral600,
                      ),
                    ),
                    const SizedBox(height: DesignSystem.space6),
                    Text(
                      'Choose your challenge:',
                      style: DesignSystem.titleMedium.copyWith(
                        color: DesignSystem.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(duration: DesignSystem.durationNormal)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              curve: DesignSystem.curveElasticOut,
              duration: DesignSystem.durationSlow,
            ),

        const SizedBox(height: DesignSystem.space8),

        // Truth or Dare buttons
        Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChoiceButton(
                  'TRUTH',
                  Icons.psychology_outlined,
                  const Color(0xFF3B82F6),
                  () => _selectChallengeType(ChallengeType.truth),
                ),
                const SizedBox(width: DesignSystem.space4),
                _buildChoiceButton(
                  'DARE',
                  Icons.flash_on_outlined,
                  const Color(0xFFEF4444),
                  () => _selectChallengeType(ChallengeType.dare),
                ),
              ],
            )
            .animate()
            .fadeIn(
              delay: DesignSystem.durationFast,
              duration: DesignSystem.durationNormal,
            )
            .slideY(
              begin: 0.2,
              end: 0,
              delay: DesignSystem.durationFast,
              duration: DesignSystem.durationNormal,
            ),
      ],
    );
  }

  Widget _buildChoiceButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedCard(
        onTap: onTap,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignSystem.radiusXl),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 48),
              const SizedBox(height: DesignSystem.space3),
              Text(
                label,
                style: DesignSystem.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeView(player, Color modeColor) {
    if (_currentChallenge == null) {
      return const Center(child: AppLoadingIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.space6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: DesignSystem.space8),

          // Challenge card
          AnimatedBuilder(
            animation: _challengeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * _challengeAnimation.value),
                child: Opacity(
                  opacity: _challengeAnimation.value,
                  child: AppCard(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignSystem.space4,
                            vertical: DesignSystem.space2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _selectedType == ChallengeType.truth
                                    ? const Color(0xFF3B82F6).withOpacity(0.1)
                                    : const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              DesignSystem.radiusFull,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _selectedType == ChallengeType.truth
                                    ? Icons.psychology_outlined
                                    : Icons.flash_on_outlined,
                                color:
                                    _selectedType == ChallengeType.truth
                                        ? const Color(0xFF3B82F6)
                                        : const Color(0xFFEF4444),
                                size: DesignSystem.iconSizeSm,
                              ),
                              const SizedBox(width: DesignSystem.space2),
                              Text(
                                _selectedType == ChallengeType.truth
                                    ? 'TRUTH'
                                    : 'DARE',
                                style: DesignSystem.labelMedium.copyWith(
                                  color:
                                      _selectedType == ChallengeType.truth
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFFEF4444),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: DesignSystem.space6),
                        Text(
                          _currentChallenge!.content,
                          style: DesignSystem.headlineSmall.copyWith(
                            color: DesignSystem.neutral900,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_currentChallenge!.difficulty > 3) ...[
                          const SizedBox(height: DesignSystem.space4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignSystem.space3,
                              vertical: DesignSystem.space1,
                            ),
                            decoration: BoxDecoration(
                              color: DesignSystem.colorWarning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                DesignSystem.radiusSm,
                              ),
                            ),
                            child: Text(
                              'Difficulty: ${_currentChallenge!.difficulty}/5',
                              style: DesignSystem.labelSmall.copyWith(
                                color: DesignSystem.colorWarning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: DesignSystem.space8),

          // Action buttons
          Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Skip',
                      onPressed: _skipChallenge,
                      type: ButtonType.secondary,
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        size: DesignSystem.iconSizeSm,
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignSystem.space4),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: 'Complete',
                      onPressed: _completeChallenge,
                      type: ButtonType.success,
                      icon: const Icon(
                        Icons.check_rounded,
                        size: DesignSystem.iconSizeSm,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(
                delay: DesignSystem.durationNormal,
                duration: DesignSystem.durationNormal,
              )
              .slideY(
                begin: 0.2,
                end: 0,
                delay: DesignSystem.durationNormal,
                duration: DesignSystem.durationNormal,
              ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/constants/app_constants.dart';
import '../../core/theme/modern_design_system.dart';
import '../../core/theme/app_icons.dart';
import '../../core/navigation/app_navigation.dart';
import '../../core/extensions/enum_extensions.dart';
import '../../data/models/challenge_model.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/modern_components.dart';
import '../widgets/spin_the_bottle_widget.dart';
import 'modern_scoreboard_screen.dart';
import 'modern_game_over_screen.dart';

class ModernGamePlayScreen extends ConsumerStatefulWidget {
  const ModernGamePlayScreen({super.key});

  @override
  ConsumerState<ModernGamePlayScreen> createState() =>
      _ModernGamePlayScreenState();
}

class _ModernGamePlayScreenState extends ConsumerState<ModernGamePlayScreen>
    with TickerProviderStateMixin {
  // Game state
  ChallengeType? _selectedType;
  Challenge? _currentChallenge;
  bool _showChallenge = false;
  bool _waitingForSpin = true;

  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _selectionController;
  late AnimationController _challengeController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _selectionController = AnimationController(
      duration: ModernDesignSystem.durationSmooth,
      vsync: this,
    );

    _challengeController = AnimationController(
      duration: ModernDesignSystem.durationSmooth,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _selectionController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _selectionController.dispose();
    _challengeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'kids':
        return ModernDesignSystem.colorKids;
      case 'teens':
        return ModernDesignSystem.colorTeens;
      case 'adult':
        return ModernDesignSystem.colorAdult;
      case 'couples':
        return ModernDesignSystem.colorCouples;
      default:
        return ModernDesignSystem.primaryColor;
    }
  }

  void _onPlayerSelected(int playerIndex) {
    final gameState = ref.read(gameProvider);
    if (gameState == null) return;

    ref.read(gameProvider.notifier).setCurrentPlayer(playerIndex);

    setState(() {
      _waitingForSpin = false;
      _showChallenge = false;
      _selectedType = null;
      _currentChallenge = null;
    });

    HapticFeedback.mediumImpact();
    _selectionController.forward(from: 0);
  }

  void _selectChallengeType(ChallengeType type) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedType = type;
    });

    Future.delayed(ModernDesignSystem.durationQuick, () {
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
    _selectionController.reverse();
    _challengeController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);

    if (gameState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentPlayer = gameState.currentPlayer;
    final modeColor = _getModeColor(gameState.mode.enumName);

    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundPrimary,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(modeColor),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, gameState, modeColor),

                // Content
                Expanded(
                  child:
                      settings.useBottleMode && _waitingForSpin
                          ? _buildSpinView(gameState, modeColor)
                          : _showChallenge
                          ? _buildChallengeView(currentPlayer, modeColor)
                          : _buildSelectionView(currentPlayer, modeColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Color modeColor) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ModernDesignSystem.backgroundPrimary,
                modeColor.withOpacity(0.05),
                ModernDesignSystem.backgroundPrimary,
              ],
              begin: Alignment(
                -1 + 2 * _backgroundController.value,
                -1 + 2 * _backgroundController.value,
              ),
              end: Alignment(
                1 - 2 * _backgroundController.value,
                1 - 2 * _backgroundController.value,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, gameState, Color modeColor) {
    return Container(
      padding: const EdgeInsets.all(ModernDesignSystem.space5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mode indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ModernDesignSystem.space4,
              vertical: ModernDesignSystem.space2,
            ),
            decoration: BoxDecoration(
              color: modeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                ModernDesignSystem.radiusFull,
              ),
              border: Border.all(color: modeColor.withOpacity(0.2), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.getModeIcon(gameState.mode.enumName),
                  size: ModernDesignSystem.iconSizeSm,
                  color: modeColor,
                ),
                const SizedBox(width: ModernDesignSystem.space2),
                Text(
                  '${gameState.mode.label} Mode',
                  style: ModernDesignSystem.labelMedium.copyWith(
                    color: modeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              // Scoreboard
              Container(
                decoration: BoxDecoration(
                  color: ModernDesignSystem.surfaceColor,
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusMd,
                  ),
                  boxShadow: ModernDesignSystem.elevationLight,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusMd,
                  ),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      AppNavigation.navigateSlideFromBottom(
                        context,
                        const ModernScoreboardScreen(),
                      );
                    },
                    borderRadius: BorderRadius.circular(
                      ModernDesignSystem.radiusMd,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(ModernDesignSystem.space3),
                      child: Icon(
                        AppIcons.leaderboard,
                        color: ModernDesignSystem.neutral700,
                        size: ModernDesignSystem.iconSizeMd,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ModernDesignSystem.space3),

              // End game
              Container(
                decoration: BoxDecoration(
                  color: ModernDesignSystem.colorError.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusMd,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radiusMd,
                  ),
                  child: InkWell(
                    onTap: () => _showEndGameDialog(context),
                    borderRadius: BorderRadius.circular(
                      ModernDesignSystem.radiusMd,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(ModernDesignSystem.space3),
                      child: Icon(
                        AppIcons.close,
                        color: ModernDesignSystem.colorError,
                        size: ModernDesignSystem.iconSizeMd,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildSpinView(gameState, Color modeColor) {
    return Padding(
      padding: const EdgeInsets.all(ModernDesignSystem.space6),
      child: Column(
        children: [
          // Instructions
          Text(
            'Spin the Bottle!',
            style: ModernDesignSystem.headlineLarge.copyWith(
              color: ModernDesignSystem.neutral900,
              fontWeight: FontWeight.w800,
            ),
          ).animate().fadeIn().scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
          ),
          const SizedBox(height: ModernDesignSystem.space3),
          Text(
            '${gameState.currentPlayer.name}, spin to select the next player',
            style: ModernDesignSystem.bodyLarge.copyWith(
              color: ModernDesignSystem.neutral600,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: ModernDesignSystem.durationQuick),

          // Bottle widget
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
        ],
      ),
    );
  }

  Widget _buildSelectionView(player, Color modeColor) {
    return AnimatedBuilder(
      animation: _selectionController,
      builder: (context, child) {
        return Opacity(
          opacity: _selectionController.value,
          child: Transform.scale(
            scale: 0.9 + (_selectionController.value * 0.1),
            child: Padding(
              padding: const EdgeInsets.all(ModernDesignSystem.space6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Player card
                  Container(
                    padding: const EdgeInsets.all(ModernDesignSystem.space8),
                    decoration: BoxDecoration(
                      color: ModernDesignSystem.surfaceColor,
                      borderRadius: BorderRadius.circular(
                        ModernDesignSystem.radius2xl,
                      ),
                      boxShadow: ModernDesignSystem.elevationMedium,
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1 + (_pulseController.value * 0.05),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      modeColor,
                                      modeColor.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: modeColor.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    player.name.isNotEmpty
                                        ? player.name
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : '?',
                                    style: ModernDesignSystem.displaySmall
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: ModernDesignSystem.space6),

                        // Name
                        Text(
                          player.name,
                          style: ModernDesignSystem.headlineLarge.copyWith(
                            color: ModernDesignSystem.neutral900,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: ModernDesignSystem.space2),

                        // Message
                        Text(
                          'The bottle chose you!',
                          style: ModernDesignSystem.bodyLarge.copyWith(
                            color: ModernDesignSystem.neutral600,
                          ),
                        ),

                        const SizedBox(height: ModernDesignSystem.space8),

                        // Choose text
                        Text(
                          'Choose your challenge:',
                          style: ModernDesignSystem.titleLarge.copyWith(
                            color: ModernDesignSystem.neutral700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: ModernDesignSystem.space10),

                  // Challenge type buttons
                  Row(
                    children: [
                      // Truth button
                      Expanded(
                        child: _buildChallengeButton(
                          type: ChallengeType.truth,
                          label: 'TRUTH',
                          icon: AppIcons.truth,
                          color: const Color(0xFF4E9FF7),
                          onTap:
                              () => _selectChallengeType(ChallengeType.truth),
                        ),
                      ),
                      const SizedBox(width: ModernDesignSystem.space5),
                      // Dare button
                      Expanded(
                        child: _buildChallengeButton(
                          type: ChallengeType.dare,
                          label: 'DARE',
                          icon: AppIcons.dare,
                          color: ModernDesignSystem.secondaryColor,
                          onTap: () => _selectChallengeType(ChallengeType.dare),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChallengeButton({
    required ChallengeType type,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusXl),
              boxShadow: ModernDesignSystem.elevationColored(color),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusXl),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(
                  ModernDesignSystem.radiusXl,
                ),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 48, color: Colors.white),
                    const SizedBox(height: ModernDesignSystem.space3),
                    Text(
                      label,
                      style: ModernDesignSystem.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .animate()
          .fadeIn(
            delay: Duration(
              milliseconds: type == ChallengeType.truth ? 200 : 300,
            ),
          )
          .slideX(begin: type == ChallengeType.truth ? -0.1 : 0.1, end: 0),
    );
  }

  Widget _buildChallengeView(player, Color modeColor) {
    if (_currentChallenge == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimatedBuilder(
      animation: _challengeController,
      builder: (context, child) {
        return Opacity(
          opacity: _challengeController.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _challengeController.value)),
            child: Padding(
              padding: const EdgeInsets.all(ModernDesignSystem.space6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Challenge card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(ModernDesignSystem.space8),
                    decoration: BoxDecoration(
                      color: ModernDesignSystem.surfaceColor,
                      borderRadius: BorderRadius.circular(
                        ModernDesignSystem.radius2xl,
                      ),
                      boxShadow: ModernDesignSystem.elevationHigh,
                    ),
                    child: Column(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ModernDesignSystem.space5,
                            vertical: ModernDesignSystem.space3,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  _selectedType == ChallengeType.truth
                                      ? [
                                        const Color(0xFF4E9FF7),
                                        const Color(0xFF3B82F6),
                                      ]
                                      : [
                                        ModernDesignSystem.secondaryColor,
                                        ModernDesignSystem.secondaryDark,
                                      ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              ModernDesignSystem.radiusFull,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _selectedType == ChallengeType.truth
                                    ? AppIcons.truth
                                    : AppIcons.dare,
                                color: Colors.white,
                                size: ModernDesignSystem.iconSizeMd,
                              ),
                              const SizedBox(width: ModernDesignSystem.space2),
                              Text(
                                _selectedType == ChallengeType.truth
                                    ? 'TRUTH'
                                    : 'DARE',
                                style: ModernDesignSystem.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: ModernDesignSystem.space8),

                        // Challenge text
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: Text(
                            _currentChallenge!.content,
                            style: ModernDesignSystem.headlineMedium.copyWith(
                              color: ModernDesignSystem.neutral900,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        if (_currentChallenge!.difficulty > 3) ...[
                          const SizedBox(height: ModernDesignSystem.space6),
                          // Difficulty indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: ModernDesignSystem.space1,
                                ),
                                child: Icon(
                                  Icons.star_rounded,
                                  size: ModernDesignSystem.iconSizeSm,
                                  color:
                                      index < _currentChallenge!.difficulty
                                          ? ModernDesignSystem.colorWarning
                                          : ModernDesignSystem.neutral300,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: ModernDesignSystem.space10),

                  // Action buttons
                  Row(
                    children: [
                      // Skip button
                      Expanded(
                        child: ModernButton(
                          label: 'Skip',
                          icon: AppIcons.next,
                          onPressed: _skipChallenge,
                          backgroundColor: ModernDesignSystem.neutral400,
                          size: ButtonSize.large,
                        ),
                      ),
                      const SizedBox(width: ModernDesignSystem.space5),
                      // Complete button
                      Expanded(
                        flex: 2,
                        child: ModernButton(
                          label: 'Complete',
                          icon: AppIcons.check,
                          onPressed: _completeChallenge,
                          backgroundColor: ModernDesignSystem.colorSuccess,
                          size: ButtonSize.large,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEndGameDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(ModernDesignSystem.space8),
                decoration: BoxDecoration(
                  color: ModernDesignSystem.surfaceColor,
                  borderRadius: BorderRadius.circular(
                    ModernDesignSystem.radius2xl,
                  ),
                  boxShadow: ModernDesignSystem.elevationHigh,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: ModernDesignSystem.colorError.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.stop_circle_rounded,
                          size: 48,
                          color: ModernDesignSystem.colorError,
                        ),
                      ),
                    ),

                    const SizedBox(height: ModernDesignSystem.space6),

                    // Title
                    Text(
                      'End Game?',
                      style: ModernDesignSystem.headlineMedium.copyWith(
                        color: ModernDesignSystem.neutral900,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: ModernDesignSystem.space3),

                    // Message
                    Text(
                      'Are you sure you want to end this game?',
                      style: ModernDesignSystem.bodyLarge.copyWith(
                        color: ModernDesignSystem.neutral600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: ModernDesignSystem.space8),

                    // Buttons
                    Row(
                      children: [
                        // Cancel
                        Expanded(
                          child: ModernButton(
                            label: 'Cancel',
                            onPressed: () => Navigator.pop(context),
                            isOutlined: true,
                            backgroundColor: ModernDesignSystem.neutral600,
                          ),
                        ),
                        const SizedBox(width: ModernDesignSystem.space4),
                        // End game
                        Expanded(
                          child: ModernButton(
                            label: 'End Game',
                            onPressed: () {
                              Navigator.pop(context);
                              ref.read(gameProvider.notifier).endGame();
                              AppNavigation.replaceWithSlide(
                                context,
                                const ModernGameOverScreen(),
                              );
                            },
                            backgroundColor: ModernDesignSystem.colorError,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
              ),
            ),
          ),
    );
  }
}

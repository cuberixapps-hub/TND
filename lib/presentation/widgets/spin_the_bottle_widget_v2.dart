import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/player_model.dart';
import '../../core/theme/modern_design_system.dart';

class SpinTheBottleWidgetV2 extends StatefulWidget {
  final List<Player> players;
  final int currentPlayerIndex;
  final Function() onSpinStart;
  final Function(int) onPlayerSelected;
  final Color modeColor;

  const SpinTheBottleWidgetV2({
    super.key,
    required this.players,
    required this.currentPlayerIndex,
    required this.onSpinStart,
    required this.onPlayerSelected,
    required this.modeColor,
  });

  @override
  State<SpinTheBottleWidgetV2> createState() => _SpinTheBottleWidgetV2State();
}

class _SpinTheBottleWidgetV2State extends State<SpinTheBottleWidgetV2>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late Animation<double> _spinAnimation;
  late Animation<double> _pulseAnimation;

  double _currentRotation = 0.0;
  bool _isSpinning = false;
  int? _selectedPlayerIndex;
  int?
  _currentlyPointingAt; // Track which player bottle is pointing at during spin

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });

    // Add listener to track which player is being pointed at during spin
    _spinController.addListener(() {
      if (_isSpinning) {
        _updatePointingPlayer();
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_isSpinning || widget.players.length < 2) return;

    print('Starting bottle spin...');
    HapticFeedback.mediumImpact();

    setState(() {
      _isSpinning = true;
      _selectedPlayerIndex = null;
      _currentlyPointingAt = null;
    });

    // Notify parent
    widget.onSpinStart();

    // Generate random spin
    final random = math.Random();
    final spins = 5 + random.nextInt(3); // 5-7 full rotations
    final extraRotation = random.nextDouble() * 2 * math.pi;
    final totalRotation = (spins * 2 * math.pi) + extraRotation;

    _spinAnimation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + totalRotation,
    ).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    _spinController.forward(from: 0);
  }

  void _updatePointingPlayer() {
    // Calculate which player the bottle is currently pointing at
    final currentAngle = _spinAnimation.value % (2 * math.pi);
    final anglePerPlayer = (2 * math.pi) / widget.players.length;
    final adjustedAngle = (currentAngle + math.pi / 2) % (2 * math.pi);
    final pointingAt =
        ((2 * math.pi - adjustedAngle) / anglePerPlayer).floor() %
        widget.players.length;

    // If pointing at a different player, update and trigger haptic
    if (pointingAt != _currentlyPointingAt) {
      setState(() {
        _currentlyPointingAt = pointingAt;
      });

      // Light haptic feedback when passing over a player
      HapticFeedback.selectionClick();
    }
  }

  void _onSpinComplete() {
    HapticFeedback.heavyImpact();

    // Update current rotation
    _currentRotation = _spinAnimation.value % (2 * math.pi);

    // Calculate selected player
    final anglePerPlayer = (2 * math.pi) / widget.players.length;
    final adjustedAngle = (_currentRotation + math.pi / 2) % (2 * math.pi);
    final selectedIndex =
        ((2 * math.pi - adjustedAngle) / anglePerPlayer).floor() %
        widget.players.length;

    setState(() {
      _isSpinning = false;
      _selectedPlayerIndex = selectedIndex;
      _currentlyPointingAt = null; // Clear pointing indicator
    });

    print('=== BOTTLE SPIN COMPLETE ===');
    print('Total players: ${widget.players.length}');
    print('Current rotation: $_currentRotation radians');
    print('Selected player index: $selectedIndex');
    print('Selected player name: ${widget.players[selectedIndex].name}');
    print('Current player index (who spun): ${widget.currentPlayerIndex}');
    print(
      'Current player name (who spun): ${widget.players[widget.currentPlayerIndex].name}',
    );
    print('========================');

    // Notify parent after delay
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onPlayerSelected(selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottleAreaSize = math.min(size.width * 0.75, size.height * 0.45);

    return Center(
      child: SizedBox(
        width: bottleAreaSize + 80, // Add padding for player avatars
        height: bottleAreaSize + 80, // Add padding for player avatars
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Players circle - minimal avatars
            ...List.generate(widget.players.length, (index) {
              final angle =
                  (index * 2 * math.pi / widget.players.length) - math.pi / 2;
              final radius = bottleAreaSize * 0.42;
              final isSelected = _selectedPlayerIndex == index;
              final isCurrent = widget.currentPlayerIndex == index;
              final isPointedAt = _currentlyPointingAt == index && _isSpinning;

              return Positioned(
                left: (bottleAreaSize + 80) / 2 + radius * math.cos(angle) - 35,
                top: (bottleAreaSize + 80) / 2 + radius * math.sin(angle) - 35,
                child: _PlayerAvatar(
                  player: widget.players[index],
                  isSelected: isSelected,
                  isCurrent: isCurrent,
                  isPointedAt: isPointedAt,
                  modeColor: widget.modeColor,
                  delay: index * 50,
                ),
              );
            }),

            // Center spin area - ultra modern design
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _isSpinning ? null : _startSpin,
                customBorder: const CircleBorder(),
                splashColor: widget.modeColor.withOpacity(0.1),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isSpinning ? 1.0 : _pulseAnimation.value,
                      child: Container(
                        width: bottleAreaSize * 0.55,
                        height: bottleAreaSize * 0.55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ModernDesignSystem.surfaceColor,
                          border: Border.all(
                            color: ModernDesignSystem.neutral200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Static indicator showing selected direction
                            if (_selectedPlayerIndex != null && !_isSpinning)
                              Positioned(
                                top: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.modeColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'SELECTED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      Text(
                                        widget
                                            .players[_selectedPlayerIndex!]
                                            .name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Animated pointer during spin
                            AnimatedBuilder(
                              animation: _spinAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle:
                                      _isSpinning
                                          ? _spinAnimation.value
                                          : _currentRotation,
                                  child: AnimatedOpacity(
                                    opacity:
                                        _isSpinning ||
                                                _selectedPlayerIndex != null
                                            ? 1.0
                                            : 0.7,
                                    duration: const Duration(milliseconds: 300),
                                    child: SizedBox(
                                      width: bottleAreaSize * 0.35,
                                      height: 40,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Main pointer beam
                                          Container(
                                            height: 3,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  widget.modeColor.withOpacity(
                                                    0.1,
                                                  ),
                                                  widget.modeColor.withOpacity(
                                                    0.8,
                                                  ),
                                                  widget.modeColor,
                                                ],
                                                stops: const [0.0, 0.7, 1.0],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          // Arrow head
                                          Positioned(
                                            right: 0,
                                            child: Icon(
                                              Icons.arrow_right_rounded,
                                              color: widget.modeColor,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Center dot
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.modeColor,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.modeColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),

                            // Tap to spin text - minimal
                            if (!_isSpinning)
                              Positioned(
                                bottom: bottleAreaSize * 0.15,
                                child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: ModernDesignSystem.space5,
                                        vertical: ModernDesignSystem.space3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ModernDesignSystem.neutral900,
                                        borderRadius: BorderRadius.circular(
                                          ModernDesignSystem.radiusFull,
                                        ),
                                      ),
                                      child: Text(
                                        'TAP TO SPIN',
                                        style: ModernDesignSystem.bodySmall
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.5,
                                            ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .scale(
                                      begin: const Offset(0.9, 0.9),
                                      end: const Offset(1.0, 1.0),
                                      duration: 300.ms,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final bool isCurrent;
  final bool isPointedAt;
  final Color modeColor;
  final int delay;

  const _PlayerAvatar({
    required this.player,
    required this.isSelected,
    required this.isCurrent,
    required this.isPointedAt,
    required this.modeColor,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Avatar circle - minimal design
              AnimatedContainer(
                duration: Duration(milliseconds: isPointedAt ? 150 : 400),
                curve: isPointedAt ? Curves.easeOut : Curves.easeOutCubic,
                width:
                    isSelected
                        ? 50
                        : isPointedAt
                        ? 48
                        : 45,
                height:
                    isSelected
                        ? 50
                        : isPointedAt
                        ? 48
                        : 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected
                          ? modeColor
                          : isPointedAt
                          ? modeColor.withOpacity(0.3)
                          : isCurrent
                          ? modeColor.withOpacity(0.15)
                          : ModernDesignSystem.surfaceColor,
                  border: Border.all(
                    color:
                        isSelected
                            ? modeColor
                            : isPointedAt
                            ? modeColor
                            : isCurrent
                            ? modeColor.withOpacity(0.4)
                            : ModernDesignSystem.neutral200,
                    width:
                        isSelected
                            ? 2.5
                            : isPointedAt
                            ? 2
                            : 1.5,
                  ),
                  boxShadow: [
                    if (isSelected || isPointedAt)
                      BoxShadow(
                        color: modeColor.withOpacity(isPointedAt ? 0.6 : 0.4),
                        blurRadius: isPointedAt ? 20 : 12,
                        spreadRadius: isPointedAt ? 3 : 0,
                      ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color:
                          isSelected
                              ? Colors.white
                              : isCurrent
                              ? modeColor
                              : ModernDesignSystem.neutral700,
                      fontSize: isSelected ? 20 : 18,
                      fontWeight:
                          isSelected
                              ? FontWeight.w700
                              : isCurrent
                              ? FontWeight.w600
                              : FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Debug index indicator
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#${player.name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Selection indicator - pulse effect
              if (isSelected)
                Positioned.fill(
                  child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: modeColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.3, 1.3),
                        duration: 1200.ms,
                        curve: Curves.easeOut,
                      )
                      .fadeOut(begin: 0.5, duration: 1200.ms),
                ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

import 'dart:math' as math;
import 'dart:ui';
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
  late AnimationController _orbitController;
  late AnimationController _glowController;
  late Animation<double> _spinAnimation;

  double _currentRotation =
      -math.pi / 2; // Start pointing up (towards first player position)
  bool _isSpinning = false;
  int? _selectedPlayerIndex;
  int? _currentlyPointingAt;

  // Fair selection tracking - ensures every player gets equal chances
  final Map<int, int> _selectionCounts = {};
  int? _predeterminedTarget; // The fairly-selected target player

  @override
  void initState() {
    super.initState();

    // Initialize selection counts for all players
    _initializeSelectionCounts();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutExpo),
    );

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });

    _spinController.addListener(() {
      if (_isSpinning) {
        _updatePointingPlayer();
      }
    });
  }

  void _initializeSelectionCounts() {
    _selectionCounts.clear();
    for (int i = 0; i < widget.players.length; i++) {
      _selectionCounts[i] = 0;
    }
  }

  @override
  void didUpdateWidget(SpinTheBottleWidgetV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset counts if players list changes
    if (oldWidget.players.length != widget.players.length) {
      _initializeSelectionCounts();
    }
  }

  /// Fair selection algorithm:
  /// 1. Find the minimum selection count among all players
  /// 2. Get all players who have that minimum count (least selected players)
  /// 3. Randomly pick one from those players
  /// This ensures everyone gets equal chances while maintaining randomness
  int _selectFairPlayer() {
    final random = math.Random();

    // Find the minimum selection count
    int minCount = _selectionCounts.values.reduce((a, b) => a < b ? a : b);

    // Get all players with the minimum selection count
    List<int> leastSelectedPlayers =
        _selectionCounts.entries
            .where((entry) => entry.value == minCount)
            .map((entry) => entry.key)
            .toList();

    // Randomly select from the least selected players
    int selectedIndex =
        leastSelectedPlayers[random.nextInt(leastSelectedPlayers.length)];

    return selectedIndex;
  }

  /// Calculate the rotation angle needed to point at a specific player
  double _getAngleForPlayer(int playerIndex) {
    // Players are positioned starting from -π/2 (top)
    // Each player is spaced by (2π / playerCount)
    final anglePerPlayer = (2 * math.pi) / widget.players.length;
    return -math.pi / 2 + (playerIndex * anglePerPlayer);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_isSpinning || widget.players.length < 2) return;

    HapticFeedback.heavyImpact();

    // Pre-determine the target using fair selection algorithm
    _predeterminedTarget = _selectFairPlayer();

    setState(() {
      _isSpinning = true;
      _selectedPlayerIndex = null;
      _currentlyPointingAt = null;
    });

    widget.onSpinStart();

    final random = math.Random();

    // Calculate the angle needed to land on the predetermined target
    final targetAngle = _getAngleForPlayer(_predeterminedTarget!);

    // Add random full rotations (5-8 spins) for visual effect
    final fullSpins = 5 + random.nextInt(4);

    // Add slight random offset within the player's sector for natural feel
    // This keeps it pointing at the same player but not always at exact center
    final anglePerPlayer = (2 * math.pi) / widget.players.length;
    final sectorOffset = (random.nextDouble() - 0.5) * anglePerPlayer * 0.6;

    // Calculate total rotation: full spins + angle to reach target + offset
    // Ensure we're always rotating forward (positive direction)
    double targetFinalAngle = targetAngle + sectorOffset;

    // Normalize current rotation
    double normalizedCurrent = _currentRotation % (2 * math.pi);
    if (normalizedCurrent < 0) normalizedCurrent += 2 * math.pi;

    // Normalize target angle
    double normalizedTarget = targetFinalAngle % (2 * math.pi);
    if (normalizedTarget < 0) normalizedTarget += 2 * math.pi;

    // Calculate the angle difference
    double angleDiff = normalizedTarget - normalizedCurrent;
    if (angleDiff < 0) angleDiff += 2 * math.pi;

    // Total rotation = full spins + angle difference to land on target
    final totalRotation = (fullSpins * 2 * math.pi) + angleDiff;

    _spinAnimation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + totalRotation,
    ).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutExpo),
    );

    _spinController.forward(from: 0);
  }

  void _updatePointingPlayer() {
    final currentAngle = _spinAnimation.value % (2 * math.pi);
    final anglePerPlayer = (2 * math.pi) / widget.players.length;
    final adjustedAngle = (currentAngle + math.pi / 2) % (2 * math.pi);
    final pointingAt =
        ((2 * math.pi - adjustedAngle) / anglePerPlayer).floor() %
        widget.players.length;

    if (pointingAt != _currentlyPointingAt) {
      setState(() {
        _currentlyPointingAt = pointingAt;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _onSpinComplete() {
    HapticFeedback.heavyImpact();

    _currentRotation = _spinAnimation.value % (2 * math.pi);

    // Use the predetermined target (fair selection) instead of calculating from angle
    // This ensures the fair algorithm's choice is respected
    final selectedIndex = _predeterminedTarget ?? 0;

    // Update selection count for fair tracking
    _selectionCounts[selectedIndex] =
        (_selectionCounts[selectedIndex] ?? 0) + 1;

    setState(() {
      _isSpinning = false;
      _selectedPlayerIndex = selectedIndex;
      _currentlyPointingAt = null;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      widget.onPlayerSelected(selectedIndex);
    });
  }

  // Avatar dimensions for proper positioning
  static const double _avatarWidth = 76.0;
  static const double _avatarHeight = 90.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Calculate the orbital circle size
    final orbitalSize = math.min(size.width * 0.72, size.height * 0.42);
    // Total area includes space for avatars that extend beyond the orbital circle
    final totalWidth = orbitalSize + _avatarWidth + 20;
    final totalHeight = orbitalSize + _avatarHeight + 20;
    // Center of the orbital system
    final centerX = totalWidth / 2;
    final centerY = totalHeight / 2;
    // Radius where player centers are positioned
    final playerRadius = orbitalSize * 0.48;

    return Center(
      child: SizedBox(
        width: totalWidth,
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Animated background glow - centered
            Positioned(
              left: centerX - orbitalSize * 0.5,
              top: centerY - orbitalSize * 0.5,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  final glowValue = 0.12 + (_glowController.value * 0.08);
                  return Container(
                    width: orbitalSize,
                    height: orbitalSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.modeColor.withOpacity(glowValue),
                          widget.modeColor.withOpacity(glowValue * 0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Outer orbital ring (decorative)
            Positioned(
              left: centerX - orbitalSize * 0.46,
              top: centerY - orbitalSize * 0.46,
              child: _buildOrbitalRing(orbitalSize * 0.92, 1, 0.06),
            ),

            // Middle orbital ring with dots
            Positioned(
              left: centerX - orbitalSize * 0.39,
              top: centerY - orbitalSize * 0.39,
              child: _buildAnimatedOrbitalRing(orbitalSize * 0.78, 8),
            ),

            // Inner orbital ring
            Positioned(
              left: centerX - orbitalSize * 0.29,
              top: centerY - orbitalSize * 0.29,
              child: _buildOrbitalRing(orbitalSize * 0.58, 1.5, 0.1),
            ),

            // Player orbit with connecting lines
            Positioned(
              left: centerX - playerRadius,
              top: centerY - playerRadius,
              child: _buildPlayerOrbit(playerRadius * 2),
            ),

            // Central interactive orb
            Positioned(
              left: centerX - orbitalSize * 0.19,
              top: centerY - orbitalSize * 0.19,
              child: _buildCentralOrb(orbitalSize * 0.38),
            ),

            // Rotating selector beam
            Positioned(
              left: centerX - playerRadius - 8,
              top: centerY - playerRadius - 8,
              child: _buildSelectorBeam(
                playerRadius * 2 + 16,
                playerRadius + 8,
              ),
            ),

            // Players positioned on orbit
            ...List.generate(widget.players.length, (index) {
              final angle =
                  (index * 2 * math.pi / widget.players.length) - math.pi / 2;
              final isSelected = _selectedPlayerIndex == index;
              final isCurrent = widget.currentPlayerIndex == index;
              final isPointedAt = _currentlyPointingAt == index && _isSpinning;

              // Position avatar so its center aligns with the orbital point
              final avatarLeft =
                  centerX + playerRadius * math.cos(angle) - _avatarWidth / 2;
              final avatarTop =
                  centerY + playerRadius * math.sin(angle) - _avatarHeight / 2;

              return Positioned(
                left: avatarLeft,
                top: avatarTop,
                child: _CelestialPlayerAvatar(
                  player: widget.players[index],
                  isSelected: isSelected,
                  isCurrent: isCurrent,
                  isPointedAt: isPointedAt,
                  modeColor: widget.modeColor,
                  delay: index * 100,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbitalRing(double size, double width, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.modeColor.withOpacity(opacity),
          width: width,
        ),
      ),
    );
  }

  Widget _buildAnimatedOrbitalRing(double size, int dotCount) {
    return AnimatedBuilder(
      animation: _orbitController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _orbitController.value * 2 * math.pi,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ring
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.modeColor.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                ),
                // Orbiting dots
                ...List.generate(dotCount, (index) {
                  final angle = (index * 2 * math.pi / dotCount);
                  final dotSize = 4.0 + (index % 3) * 2;
                  return Positioned(
                    left:
                        size / 2 +
                        (size / 2 - 4) * math.cos(angle) -
                        dotSize / 2,
                    top:
                        size / 2 +
                        (size / 2 - 4) * math.sin(angle) -
                        dotSize / 2,
                    child: Container(
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.modeColor.withOpacity(
                          0.2 + (index % 3) * 0.1,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerOrbit(double diameter) {
    return CustomPaint(
      size: Size(diameter, diameter),
      painter: _OrbitLinePainter(
        playerCount: widget.players.length,
        color: widget.modeColor.withOpacity(0.1),
        radius: diameter / 2,
      ),
    );
  }

  Widget _buildCentralOrb(double orbSize) {
    return GestureDetector(
      onTap: _isSpinning ? null : _startSpin,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale =
              _isSpinning ? 1.0 : 1.0 + (_pulseController.value * 0.03);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: orbSize,
              height: orbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.95),
                    ModernDesignSystem.neutral100,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  // Outer glow
                  BoxShadow(
                    color: widget.modeColor.withOpacity(0.25),
                    blurRadius: 40,
                    spreadRadius: -5,
                  ),
                  // Main shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                  // Inner highlight
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    blurRadius: 20,
                    spreadRadius: -10,
                    offset: const Offset(-8, -8),
                  ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Inner gradient sphere effect
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.modeColor.withOpacity(0.05),
                              Colors.transparent,
                              widget.modeColor.withOpacity(0.08),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),

                      // Spinning indicator when active
                      if (_isSpinning)
                        SizedBox(
                          width: orbSize * 0.6,
                          height: orbSize * 0.6,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.modeColor.withOpacity(0.4),
                            ),
                          ),
                        ),

                      // Center content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_selectedPlayerIndex != null && !_isSpinning) ...[
                            // Selected player display
                            Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.modeColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.modeColor.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    widget
                                                .players[_selectedPlayerIndex!]
                                                .name
                                                .length >
                                            10
                                        ? '${widget.players[_selectedPlayerIndex!].name.substring(0, 9)}…'
                                        : widget
                                            .players[_selectedPlayerIndex!]
                                            .name,
                                    style: ModernDesignSystem.titleSmall
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1.0, 1.0),
                                  duration: 400.ms,
                                  curve: Curves.easeOutBack,
                                ),
                          ] else if (!_isSpinning) ...[
                            // Tap to spin content
                            Icon(
                              Icons.touch_app_rounded,
                              color: widget.modeColor.withOpacity(0.6),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'TAP',
                              style: ModernDesignSystem.headlineSmall.copyWith(
                                color: ModernDesignSystem.neutral800,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'TO SPIN',
                              style: ModernDesignSystem.labelSmall.copyWith(
                                color: ModernDesignSystem.neutral500,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ] else ...[
                            // Spinning state
                            Text(
                              '•••',
                              style: TextStyle(
                                color: widget.modeColor,
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectorBeam(double diameter, double beamLength) {
    return AnimatedBuilder(
      animation: _spinAnimation,
      builder: (context, child) {
        final rotation = _isSpinning ? _spinAnimation.value : _currentRotation;
        return Transform.rotate(
          angle: rotation,
          child: AnimatedOpacity(
            opacity: _isSpinning || _selectedPlayerIndex != null ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              width: diameter,
              height: diameter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Beam line pointing right (0 degrees)
                  Positioned(
                    right: 8,
                    child: Container(
                      width: beamLength * 0.7,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            widget.modeColor.withOpacity(0.2),
                            widget.modeColor.withOpacity(0.6),
                            widget.modeColor,
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: widget.modeColor.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Beam tip glow
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.modeColor,
                        boxShadow: [
                          BoxShadow(
                            color: widget.modeColor.withOpacity(0.7),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: widget.modeColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
}

// Custom painter for orbit connection lines
class _OrbitLinePainter extends CustomPainter {
  final int playerCount;
  final Color color;
  final double radius;

  _OrbitLinePainter({
    required this.playerCount,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Draw lines from center to each player position
    for (int i = 0; i < playerCount; i++) {
      final angle = (i * 2 * math.pi / playerCount) - math.pi / 2;
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CelestialPlayerAvatar extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final bool isCurrent;
  final bool isPointedAt;
  final Color modeColor;
  final int delay;

  const _CelestialPlayerAvatar({
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
          width: _SpinTheBottleWidgetV2State._avatarWidth,
          height: _SpinTheBottleWidgetV2State._avatarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar orb with effects
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow ring for selected/pointed
                    if (isSelected || isPointedAt)
                      AnimatedContainer(
                        duration: Duration(
                          milliseconds: isPointedAt ? 150 : 400,
                        ),
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: modeColor.withOpacity(
                              isSelected ? 0.5 : 0.35,
                            ),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: modeColor.withOpacity(
                                isSelected ? 0.4 : 0.25,
                              ),
                              blurRadius: isSelected ? 18 : 12,
                              spreadRadius: isSelected ? 3 : 1,
                            ),
                          ],
                        ),
                      ),

                    // Main avatar circle
                    AnimatedContainer(
                      duration: Duration(milliseconds: isPointedAt ? 150 : 350),
                      curve: Curves.easeOutCubic,
                      width:
                          isSelected
                              ? 50
                              : isPointedAt
                              ? 48
                              : 46,
                      height:
                          isSelected
                              ? 50
                              : isPointedAt
                              ? 48
                              : 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient:
                            isSelected
                                ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    modeColor,
                                    modeColor.withOpacity(0.85),
                                  ],
                                )
                                : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    isCurrent
                                        ? modeColor.withOpacity(0.12)
                                        : Colors.white,
                                    isCurrent
                                        ? modeColor.withOpacity(0.06)
                                        : ModernDesignSystem.neutral50,
                                  ],
                                ),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Colors.white
                                  : isPointedAt
                                  ? modeColor
                                  : isCurrent
                                  ? modeColor.withOpacity(0.35)
                                  : Colors.white,
                          width: isSelected ? 2.5 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isSelected || isPointedAt
                                    ? modeColor.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.08),
                            blurRadius: isSelected ? 14 : 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          player.name.isNotEmpty
                              ? player.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : isCurrent
                                    ? modeColor
                                    : ModernDesignSystem.neutral700,
                            fontSize: isSelected ? 20 : 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Pulse animation for selected
                    if (isSelected)
                      Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: modeColor.withOpacity(0.25),
                                width: 2,
                              ),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .scale(
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.4, 1.4),
                            duration: 1400.ms,
                          )
                          .fadeOut(begin: 0.4, duration: 1400.ms),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Player name badge
              Container(
                constraints: const BoxConstraints(maxWidth: 72),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? modeColor.withOpacity(0.12)
                          : Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  player.name.length > 8
                      ? '${player.name.substring(0, 7)}…'
                      : player.name,
                  style: ModernDesignSystem.labelSmall.copyWith(
                    color:
                        isSelected ? modeColor : ModernDesignSystem.neutral700,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
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
          duration: 500.ms,
          curve: Curves.easeOutBack,
        );
  }
}

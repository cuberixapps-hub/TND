import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../../core/physics/bottle_physics.dart';
import '../../data/models/player_model.dart';

class SpinTheBottleWidget extends StatefulWidget {
  final List<Player> players;
  final int currentPlayerIndex;
  final Function() onSpinStart;
  final Function(int) onPlayerSelected;
  final Color modeColor;
  final bool isEnabled;

  const SpinTheBottleWidget({
    super.key,
    required this.players,
    required this.currentPlayerIndex,
    required this.onSpinStart,
    required this.onPlayerSelected,
    required this.modeColor,
    this.isEnabled = true,
  });

  @override
  State<SpinTheBottleWidget> createState() => _SpinTheBottleWidgetState();
}

class _SpinTheBottleWidgetState extends State<SpinTheBottleWidget>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  double _currentAngle = 0.0;
  bool _isSpinning = false;
  int? _selectedPlayerIndex;

  // Gesture detection
  Offset? _startPosition;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Max duration
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);

    _spinController.addListener(() {
      setState(() {
        _currentAngle = _spinController.value;
      });
    });

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onSpinComplete() {
    HapticFeedback.mediumImpact();

    // Calculate selected player
    final selectedIndex = BottlePhysicsCalculator.calculateSelectedPlayer(
      _currentAngle,
      widget.players.length,
    );

    setState(() {
      _isSpinning = false;
      _selectedPlayerIndex = selectedIndex;
    });

    _glowController.forward();

    // Notify parent after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onPlayerSelected(selectedIndex);
      _glowController.reverse();
    });
  }

  void _startSpin(Offset velocity) {
    print(
      '_startSpin called - isEnabled: ${widget.isEnabled}, isSpinning: $_isSpinning, players: ${widget.players.length}',
    );

    if (!widget.isEnabled || _isSpinning || widget.players.length < 2) {
      print('Spin cancelled - conditions not met');
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      _isSpinning = true;
      _selectedPlayerIndex = null;
    });

    // Notify parent that spinning has started
    widget.onSpinStart();

    // Calculate initial velocity
    double initialVelocity = BottlePhysicsCalculator.calculateVelocity(
      velocity,
    );
    initialVelocity = BottlePhysicsCalculator.addRandomness(initialVelocity);

    // Create physics simulation
    final simulation = BottleSpinSimulation(
      initialVelocity: initialVelocity,
      friction: 0.35,
      initialPosition: _currentAngle,
    );

    // Animate with physics
    _spinController.animateWith(simulation);
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.isEnabled || _isSpinning) return;
    _startPosition = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.isEnabled || _isSpinning) return;
    // Track gesture movement if needed
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.isEnabled || _isSpinning || _startPosition == null) return;

    // Use the velocity from the drag end
    _startSpin(details.velocity.pixelsPerSecond);
  }

  void _handleTap() {
    print(
      'Tap detected - isEnabled: ${widget.isEnabled}, isSpinning: $_isSpinning',
    );

    if (!widget.isEnabled || _isSpinning) {
      print('Tap ignored - widget not enabled or already spinning');
      return;
    }

    // Generate random velocity for tap
    final random = math.Random();
    final angle = random.nextDouble() * 2 * math.pi;
    final magnitude = 300 + random.nextDouble() * 200;
    final velocity = Offset(
      magnitude * math.cos(angle),
      magnitude * math.sin(angle),
    );

    print('Starting spin with velocity: $velocity');
    _startSpin(velocity);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final containerSize = math.min(size.width * 0.9, size.height * 0.5);

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: containerSize * 0.95,
            height: containerSize * 0.95,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DesignSystem.neutral100,
              border: Border.all(
                color: widget.modeColor.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.modeColor.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Player avatars in circle
          ...List.generate(widget.players.length, (index) {
            final angle =
                (index * 2 * math.pi / widget.players.length) - math.pi / 2;
            final radius = containerSize * 0.4;
            final player = widget.players[index];
            final isSelected = _selectedPlayerIndex == index;
            final isCurrent = widget.currentPlayerIndex == index;

            return Positioned(
              left: containerSize / 2 + radius * math.cos(angle) - 30,
              top: containerSize / 2 + radius * math.sin(angle) - 30,
              child: _PlayerAvatar(
                player: player,
                isSelected: isSelected,
                isCurrent: isCurrent,
                modeColor: widget.modeColor,
                glowAnimation: isSelected ? _glowAnimation : null,
              ),
            );
          }),

          // Center spin area
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            onTap: _handleTap,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isSpinning ? 1.0 : _pulseAnimation.value,
                  child: Container(
                    width: containerSize * 0.5,
                    height: containerSize * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.modeColor.withOpacity(0.2),
                          widget.modeColor.withOpacity(0.05),
                        ],
                      ),
                      boxShadow:
                          _isSpinning
                              ? [
                                BoxShadow(
                                  color: widget.modeColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                              : null,
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Bottle
                          Transform.rotate(
                            angle: _currentAngle,
                            child: _BottleWidget(
                              color: widget.modeColor,
                              isSpinning: _isSpinning,
                            ),
                          ),

                          // Tap to spin text
                          if (!_isSpinning && widget.isEnabled)
                            IgnorePointer(
                              child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: DesignSystem.space3,
                                      vertical: DesignSystem.space2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: DesignSystem.neutral900
                                          .withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(
                                        DesignSystem.radiusSm,
                                      ),
                                    ),
                                    child: Text(
                                      'TAP TO SPIN',
                                      style: DesignSystem.labelSmall.copyWith(
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  )
                                  .animate(
                                    onPlay: (controller) => controller.repeat(),
                                  )
                                  .fadeIn(duration: DesignSystem.durationSlow)
                                  .then(delay: const Duration(seconds: 2))
                                  .fadeOut(duration: DesignSystem.durationSlow)
                                  .then(delay: const Duration(seconds: 1)),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BottleWidget extends StatelessWidget {
  final Color color;
  final bool isSpinning;

  const _BottleWidget({required this.color, required this.isSpinning});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 120,
      child: CustomPaint(
        painter: _BottlePainter(color: color, isSpinning: isSpinning),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  final Color color;
  final bool isSpinning;

  _BottlePainter({required this.color, required this.isSpinning});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final outlinePaint =
        Paint()
          ..color = color.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Create bottle path
    final path = Path();

    // Bottle neck (top)
    path.moveTo(size.width * 0.4, 0);
    path.lineTo(size.width * 0.6, 0);
    path.lineTo(size.width * 0.6, size.height * 0.3);
    path.lineTo(size.width * 0.7, size.height * 0.4);

    // Bottle body
    path.lineTo(size.width * 0.8, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width * 0.2,
      size.height * 0.8,
    );
    path.lineTo(size.width * 0.3, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.3);
    path.close();

    // Add glow effect when spinning
    if (isSpinning) {
      final glowPaint =
          Paint()
            ..color = color.withOpacity(0.3)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawPath(path, glowPaint);
    }

    // Draw bottle
    canvas.drawPath(path, paint);
    canvas.drawPath(path, outlinePaint);

    // Add highlight
    final highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.45, size.height * 0.1);
    highlightPath.lineTo(size.width * 0.5, size.height * 0.1);
    highlightPath.lineTo(size.width * 0.5, size.height * 0.5);
    highlightPath.lineTo(size.width * 0.45, size.height * 0.5);
    highlightPath.close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PlayerAvatar extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final bool isCurrent;
  final Color modeColor;
  final Animation<double>? glowAnimation;

  const _PlayerAvatar({
    required this.player,
    required this.isSelected,
    required this.isCurrent,
    required this.modeColor,
    this.glowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarColor(),
        border: Border.all(
          color:
              isSelected
                  ? modeColor
                  : isCurrent
                  ? modeColor.withOpacity(0.5)
                  : DesignSystem.neutral300,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: modeColor.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          player.name.substring(0, 1).toUpperCase(),
          style: DesignSystem.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    if (glowAnimation != null) {
      avatar = AnimatedBuilder(
        animation: glowAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 + (0.2 * glowAnimation!.value),
            child: Opacity(
              opacity: 1 - (0.3 * glowAnimation!.value),
              child: child,
            ),
          );
        },
        child: avatar,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        const SizedBox(height: DesignSystem.space2),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.space2,
            vertical: DesignSystem.space1,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? modeColor
                    : isCurrent
                    ? modeColor.withOpacity(0.2)
                    : DesignSystem.neutral200,
            borderRadius: BorderRadius.circular(DesignSystem.radiusSm),
          ),
          child: Text(
            player.name,
            style: DesignSystem.labelSmall.copyWith(
              color:
                  isSelected
                      ? Colors.white
                      : isCurrent
                      ? modeColor
                      : DesignSystem.neutral700,
              fontWeight:
                  isSelected || isCurrent ? FontWeight.w600 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getAvatarColor() {
    final colors = [
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFFF97316),
    ];

    return colors[player.name.hashCode % colors.length];
  }
}

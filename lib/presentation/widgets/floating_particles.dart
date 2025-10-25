import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingParticle {
  Offset position;
  double radius;
  double opacity;
  double speed;
  double angle;

  FloatingParticle({
    required this.position,
    required this.radius,
    required this.opacity,
    required this.speed,
    required this.angle,
  });
}

class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Color color;
  final double maxRadius;
  final double minRadius;
  final double maxSpeed;
  final double minSpeed;

  const FloatingParticles({
    super.key,
    this.particleCount = 20,
    this.color = Colors.white,
    this.maxRadius = 3,
    this.minRadius = 1,
    this.maxSpeed = 0.5,
    this.minSpeed = 0.1,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<FloatingParticle> particles;
  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _initializeParticles();

    _controller.addListener(_updateParticles);
  }

  void _initializeParticles() {
    particles = List.generate(widget.particleCount, (index) {
      return FloatingParticle(
        position: Offset(random.nextDouble(), random.nextDouble()),
        radius:
            widget.minRadius +
            random.nextDouble() * (widget.maxRadius - widget.minRadius),
        opacity: 0.1 + random.nextDouble() * 0.4,
        speed:
            widget.minSpeed +
            random.nextDouble() * (widget.maxSpeed - widget.minSpeed),
        angle: random.nextDouble() * 2 * math.pi,
      );
    });
  }

  void _updateParticles() {
    setState(() {
      for (var particle in particles) {
        // Update position based on angle and speed
        particle.position = Offset(
          (particle.position.dx +
                  math.cos(particle.angle) * particle.speed / 100) %
              1,
          (particle.position.dy +
                  math.sin(particle.angle) * particle.speed / 100) %
              1,
        );

        // Slowly change angle for organic movement
        particle.angle += (random.nextDouble() - 0.5) * 0.1;

        // Gently pulse opacity
        particle.opacity =
            0.1 +
            (0.4 *
                (0.5 +
                    0.5 *
                        math.sin(
                          _controller.value * 2 * math.pi + particle.angle,
                        )));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: ParticlesPainter(
            particles: particles,
            color: widget.color,
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        );
      },
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final List<FloatingParticle> particles;
  final Color color;
  final Size size;

  ParticlesPainter({
    required this.particles,
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = color.withOpacity(particle.opacity);

      canvas.drawCircle(
        Offset(
          particle.position.dx * size.width,
          particle.position.dy * size.height,
        ),
        particle.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}

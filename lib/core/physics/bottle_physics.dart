import 'dart:math' as math;
import 'package:flutter/physics.dart';
import 'package:flutter/animation.dart';

/// Custom physics simulation for bottle spinning
class BottleSpinSimulation extends Simulation {
  final double initialVelocity;
  final double friction;
  final double mass;

  late double _position;
  late double _velocity;

  BottleSpinSimulation({
    required this.initialVelocity,
    this.friction = 0.3,
    this.mass = 1.0,
    double initialPosition = 0.0,
  }) {
    _position = initialPosition;
    _velocity = initialVelocity;
  }

  @override
  double x(double time) {
    // Calculate position based on velocity and friction
    if (_velocity == 0) return _position;

    // Apply friction to slow down the spin
    final frictionForce = friction * mass;
    final deceleration = frictionForce / mass;

    // Calculate velocity at time t
    double currentVelocity = initialVelocity - (deceleration * time);
    if (currentVelocity <= 0) {
      // Calculate when the bottle stopped
      final stopTime = initialVelocity / deceleration;
      // Return final position
      return _position +
          (initialVelocity * stopTime -
              0.5 * deceleration * stopTime * stopTime);
    }

    // Calculate position at time t
    return _position +
        (initialVelocity * time - 0.5 * deceleration * time * time);
  }

  @override
  double dx(double time) {
    // Calculate velocity at time t
    final frictionForce = friction * mass;
    final deceleration = frictionForce / mass;

    double currentVelocity = initialVelocity - (deceleration * time);
    return currentVelocity > 0 ? currentVelocity : 0;
  }

  @override
  bool isDone(double time) {
    return dx(time) <= 0;
  }
}

/// Calculates bottle physics based on swipe gesture
class BottlePhysicsCalculator {
  static const double maxVelocity = 15.0; // radians per second
  static const double minVelocity = 3.0; // minimum spin velocity
  static const double velocityMultiplier = 0.01;

  /// Calculate initial velocity from swipe gesture
  static double calculateVelocity(Offset velocity) {
    // Calculate magnitude of swipe
    final magnitude = velocity.distance;

    // Convert to angular velocity (considering circular motion)
    double angularVelocity = magnitude * velocityMultiplier;

    // Clamp between min and max
    angularVelocity = angularVelocity.clamp(minVelocity, maxVelocity);

    // Determine direction based on swipe direction
    // Clockwise if swiping right/down, counter-clockwise if left/up
    final direction = (velocity.dx + velocity.dy) > 0 ? 1.0 : -1.0;

    return angularVelocity * direction;
  }

  /// Calculate which player the bottle is pointing to
  static int calculateSelectedPlayer(double finalAngle, int playerCount) {
    // Normalize angle to 0-2π range
    final normalizedAngle = finalAngle % (2 * math.pi);

    // Calculate angle per player
    final anglePerPlayer = (2 * math.pi) / playerCount;

    // Calculate which player segment the bottle is pointing to
    // Add π/2 offset because bottle points upward at 0 radians
    final adjustedAngle = (normalizedAngle + math.pi / 2) % (2 * math.pi);

    // Calculate player index (0-based)
    int playerIndex = (adjustedAngle / anglePerPlayer).floor();

    return playerIndex % playerCount;
  }

  /// Add randomness to make spinning more realistic
  static double addRandomness(double velocity) {
    final random = math.Random();
    // Add ±10% randomness
    final randomFactor = 0.9 + (random.nextDouble() * 0.2);
    return velocity * randomFactor;
  }
}





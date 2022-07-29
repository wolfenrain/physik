import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// {@template particle}
/// A particle represents a point in space with a position and velocity.
/// {@endtemplate}
mixin Particle on PositionComponent {
  /// The previous position of the particle.
  @visibleForTesting
  final Vector2 oldPosition = Vector2.zero();

  /// The velocity of the particle.
  @visibleForTesting
  final Vector2 velocity = Vector2.zero();

  /// The forces applied on the particle.
  Vector2 forces = Vector2.zero();

  /// Indicates if the particle is moving.
  bool isMoving = true;

  /// The mass of the particle.
  double mass = 1;

  @override
  @mustCallSuper
  Future<void>? onLoad() {
    oldPosition.setFrom(position);
    return super.onLoad();
  }

  /// Update the particle's position and apply [forces] to [velocity].
  void updatePosition(double dt) {
    if (!isMoving) return;

    // Store the position so we can calculate the velocity later on.
    oldPosition.setFrom(position);

    velocity.add(forces.clone()..scale(dt));
    position.add(velocity * dt);
  }

  /// Update [velocity] and reset the [forces].
  void updateForces(double dt) {
    velocity.setFrom((position - oldPosition)..scale(1 / dt));
    forces.setZero();
  }
}

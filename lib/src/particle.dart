import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A particle represents a point in space with a position and velocity.
mixin Particle on PositionComponent {
  /// The previous position of the particle.
  final Vector2 _oldPosition = Vector2.zero();

  /// The velocity of the particle.
  final Vector2 _velocity = Vector2.zero();

  /// The forces applied on the particle.
  Vector2 forces = Vector2.zero();

  /// Indicates if the particle is moving.
  bool isMoving = true;

  @override
  @mustCallSuper
  Future<void>? onLoad() {
    _oldPosition.setFrom(position);
    return super.onLoad();
  }

  /// Update the particle's position and apply [forces] to velocity.
  void updatePosition(double dt) {
    if (!isMoving) return;

    // Store the position so we can calculate the velocity later on.
    _oldPosition.setFrom(position);

    _velocity.add(forces.clone()..scale(dt));
    position.add(_velocity * dt);
  }

  /// Update velocity and reset the [forces].
  void updateForces(double dt) {
    _velocity.setFrom((position - _oldPosition)..scale(1 / dt));
    forces.setZero();
  }
}

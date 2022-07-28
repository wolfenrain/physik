import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:physik/physik.dart';

/// Physics solver, it simulates physics by applying verlet integration.
///
/// You can add custom physics logic by implementing the [apply] and [solve]
/// methods. The [apply] method is called before the [solve] method.
mixin PhysicsSolver on Component {
  /// List of particles that the solver is aware off.
  late final List<Particle> particles;

  /// The amount of sub-steps per update in which physics will be solved.
  int subSteps = 8;

  /// The gravity to apply.
  Vector2 gravity = Vector2(0, 1500);

  @override
  Future<void>? onLoad() {
    children.register<Particle>();
    particles = children.query<Particle>();

    return super.onLoad();
  }

  @override
  @mustCallSuper
  void update(double dt) {
    final subStepDt = dt / subSteps;

    for (var i = subSteps; i > 0; i--) {
      applyGravity();
      updatePositions(subStepDt);
      apply(subStepDt);
      solve(subStepDt);
      updateForces(subStepDt);
    }
  }

  /// Apply the gravity to all particles.
  void applyGravity() {
    for (final particle in particles) {
      particle.forces.add(gravity);
    }
  }

  /// Update the positions of all particles.
  void updatePositions(double dt) {
    for (final particle in particles) {
      particle.updatePosition(dt);
    }
  }

  /// Update the forces of all particles.
  void updateForces(double dt) {
    for (final particle in particles) {
      particle.updateForces(dt);
    }
  }

  /// Apply custom physics logic, like applying constraints to particles.
  void apply(double dt);

  /// Solve custom physics logic, like collisions.
  void solve(double dt);
}

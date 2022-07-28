import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:physik/physik.dart';

/// TODO(wolfen): write documentation
mixin PhysicsSolver on Component {
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

  void applyGravity() {
    for (final particle in particles) {
      particle.forces.add(gravity);
    }
  }

  void updatePositions(double dt) {
    for (final particle in particles) {
      particle.updatePosition(dt);
    }
  }

  void updateForces(double dt) {
    for (final particle in particles) {
      particle.updateForces(dt);
    }
  }

  void apply(double dt);

  void solve(double dt);
}

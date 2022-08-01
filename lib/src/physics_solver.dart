import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:physik/physik.dart';

/// {@template physics_solver}
/// Physics solver, it simulates physics by applying verlet integration.
///
/// You can add custom physics logic by implementing the [apply] and [solve]
/// methods. The [apply] method is called before the [solve] method.
/// {@endtemplate}
mixin PhysicsSolver on Component {
  /// List of particles that the solver is aware off.
  late final List<Particle> particles;

  /// List of constraints that the solver is aware off.
  late final List<LinkConstraint> constraints;

  /// The amount of sub-steps per update in which physics will be solved.
  int subSteps = 8;

  /// The amount of iterations to run to solve the constraints.
  int solverIterations = 1;

  /// The gravity to apply.
  Vector2 gravity = Vector2(0, 1500);

  @override
  Future<void>? onLoad() {
    children.register<Particle>();
    particles = children.query<Particle>();

    children.register<LinkConstraint>();
    constraints = children.query<LinkConstraint>();

    return super.onLoad();
  }

  @override
  @mustCallSuper
  void update(double dt) {
    removeBrokenConstraints();

    final subStepDt = dt / subSteps;

    for (var i = subSteps; i > 0; i--) {
      applyGravity();
      apply(subStepDt);
      updatePositions(subStepDt);
      solveConstraints();
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

  /// Solve the constraints in multiple iterations.
  void solveConstraints() {
    for (var i = solverIterations; i > 0; i--) {
      for (final constraint in constraints) {
        constraint.solve();
      }
    }
  }

  /// Remove any broken constraints from the solver.
  void removeBrokenConstraints() {
    final brokenConstraints = constraints.where((c) => !c.isValid);
    for (final constraint in brokenConstraints) {
      constraint.removeFromParent();
    }
  }

  /// Apply custom physics logic, like applying constraints to particles.
  ///
  /// This is run before any forces are applied to particles.
  void apply(double dt);

  /// Solve custom physics logic, like collisions.
  ///
  /// This is run after forces are applied to particles and before the forces
  /// are cleared.
  void solve(double dt);
}

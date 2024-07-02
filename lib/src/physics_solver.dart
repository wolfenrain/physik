import 'dart:async';

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
  FutureOr<void> onLoad() {
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
    final particlesLength = particles.length;

    for (var i = subSteps; i > 0; i--) {
      for (var p = 0; p < particlesLength; p++) {
        applyGravity(p);
        apply(subStepDt, p);
        updatePositions(subStepDt, p);
      }
      solveConstraints();
      for (var p = 0; p < particlesLength; p++) {
        solve(subStepDt, p);
        updateForces(subStepDt, p);
      }
    }
  }

  /// Apply the gravity on a particle.
  void applyGravity(int particleIndex) {
    particles[particleIndex].forces.add(gravity);
  }

  /// Update the positions on a particle.
  void updatePositions(double dt, int particleIndex) {
    particles[particleIndex].updatePosition(dt);
  }

  /// Update the forces on a particle.
  void updateForces(double dt, int particleIndex) {
    particles[particleIndex].updateForces(dt);
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

  /// Apply custom physics logic, like applying constraints to a particle.
  ///
  /// This is run before any forces are applied to particles.
  void apply(double dt, int particleIndex);

  /// Solve custom physics logic, like collisions.
  ///
  /// This is run after forces are applied to particles and before the forces
  /// are cleared.
  void solve(double dt, int particleIndex);
}

// import 'package:flame/components.dart';
// import 'package:flutter/material.dart';
// import 'package:physik/physik.dart';

// /// {@template physics_solver}
// /// Physics solver, it simulates physics by applying verlet integration.
// ///
// /// You can add custom physics logic by implementing the [apply] and [solve]
// /// methods. The [apply] method is called before the [solve] method.
// /// {@endtemplate}
// mixin PhysicsSolver on Component {
//   /// List of particles that the solver is aware off.
//   late final List<Particle> particles;

//   /// List of constraints that the solver is aware off.
//   late final List<LinkConstraint> constraints;

//   /// The amount of sub-steps per update in which physics will be solved.
//   int subSteps = 8;

//   /// The amount of iterations to run to solve the constraints.
//   int solverIterations = 1;

//   /// The gravity to apply.
//   Vector2 gravity = Vector2(0, 1500);

//   @override
//   Future<void>? onLoad() {
//     children.register<Particle>();
//     particles = children.query<Particle>();

//     children.register<LinkConstraint>();
//     constraints = children.query<LinkConstraint>();

//     return super.onLoad();
//   }

//   @override
//   @mustCallSuper
//   void update(double dt) {
//     removeBrokenConstraints();

//     final subStepDt = dt / subSteps;

//     for (var i = subSteps; i > 0; i--) {
//       for (final particle in particles) {
//         applyGravity(particle);
//         apply(subStepDt, particle);
//         updatePositions(subStepDt, particle);
//       }
//       solveConstraints();
//       for (final particle in particles) {
//         solve(subStepDt, particle);
//         updateForces(subStepDt, particle);
//       }
//     }
//   }

//   /// Apply the gravity on a particle.
//   void applyGravity(Particle particle) {
//     particle.forces.add(gravity);
//   }

//   /// Update the positions on a particle.
//   void updatePositions(double dt, Particle particle) {
//     particle.updatePosition(dt);
//   }

//   /// Update the forces on a particle.
//   void updateForces(double dt, Particle particle) {
//     particle.updateForces(dt);
//   }

//   /// Solve the constraints in multiple iterations.
//   void solveConstraints() {
//     for (var i = solverIterations; i > 0; i--) {
//       for (final constraint in constraints) {
//         constraint.solve();
//       }
//     }
//   }

//   /// Remove any broken constraints from the solver.
//   void removeBrokenConstraints() {
//     final brokenConstraints = constraints.where((c) => !c.isValid);
//     for (final constraint in brokenConstraints) {
//       constraint.removeFromParent();
//     }
//   }

//   /// Apply custom physics logic, like applying constraints to a particle.
//   ///
//   /// This is run before any forces are applied to particles.
//   void apply(double dt, Particle particle);

//   /// Solve custom physics logic, like collisions.
//   ///
//   /// This is run after forces are applied to particles and before the forces
//   /// are cleared.
//   void solve(double dt, Particle particle);
// }

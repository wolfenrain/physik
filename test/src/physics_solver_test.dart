// ignore_for_file: prefer_const_constructors, cascade_invocations
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physik/physik.dart';

class _TestParticle extends PositionComponent with Particle {
  _TestParticle({super.position});
}

class _TestSolver extends Component with PhysicsSolver {
  _TestSolver({
    int subStep = 8,
    this.testApply,
    this.testSolve,
  }) : _subStep = subStep;

  final int _subStep;

  final ValueChanged<double>? testApply;

  final ValueChanged<double>? testSolve;

  @override
  int get subSteps => _subStep;

  @override
  void apply(double dt) {
    testApply?.call(dt);
  }

  @override
  void solve(double dt) {
    testSolve?.call(dt);
  }
}

void main() {
  group('PhysicsSolver', () {
    flameGame.test(
      'register and query the particle children in onLoad',
      (game) async {
        final solver = _TestSolver();
        await game.ensureAdd(solver);

        expect(solver.particles, isEmpty);

        final particle = _TestParticle(position: Vector2(1, 2));
        await solver.ensureAdd(particle);

        expect(solver.particles, isNotEmpty);
        expect(solver.particles, contains(particle));
      },
    );

    flameGame.test(
      'solves physics based on a sub step value',
      (game) async {
        var applyCalled = 0;
        var solveApply = 0;
        final solver = _TestSolver(
          testApply: (double dt) {
            expect(dt, equals(0.25));
            applyCalled++;
          },
          testSolve: (double dt) {
            expect(dt, equals(0.25));
            solveApply++;
          },
          subStep: 4,
        );
        await game.ensureAdd(solver);

        solver.update(1);

        expect(applyCalled, equals(4));
        expect(solveApply, equals(4));
      },
    );

    flameGame.test('applies physics to the particles', (game) async {
      final solver = _TestSolver(subStep: 1);
      await game.ensureAdd(solver);

      final particle = _TestParticle(position: Vector2(1, 2));
      await solver.ensureAdd(particle);

      solver.update(0.5);

      expect(particle.velocity, closeToVector(solver.gravity * 0.5));
      expect(
        particle.position,
        closeToVector(Vector2(1, 2 + solver.gravity.y * 0.25)),
      );
    });

    group('applyGravity', () {
      flameGame.test('applies gravity to the particles', (game) async {
        final solver = _TestSolver(subStep: 1);
        await game.ensureAdd(solver);

        final particle = _TestParticle(position: Vector2(1, 2));
        await solver.ensureAdd(particle);

        solver.applyGravity();

        expect(particle.forces, closeToVector(solver.gravity));
        expect(particle.position, closeToVector(Vector2(1, 2)));
      });
    });

    group('updatePositions', () {
      flameGame.test(
        'updates positions of the particles correctly',
        (game) async {
          final solver = _TestSolver(subStep: 1);
          await game.ensureAdd(solver);

          final particle = _TestParticle(position: Vector2.zero());
          await solver.ensureAdd(particle);

          particle.forces.setFrom(Vector2(4, 4));
          solver.updatePositions(0.5);

          expect(particle.velocity, closeToVector(Vector2(2, 2)));
          expect(particle.position, closeToVector(Vector2(1, 1)));
        },
      );
    });

    group('updateForces', () {
      flameGame.test(
        'updates forces of the particles correctly',
        (game) async {
          final solver = _TestSolver(subStep: 1);
          await game.ensureAdd(solver);

          final particle = _TestParticle(position: Vector2.zero());
          await solver.ensureAdd(particle);

          particle.position.setFrom(Vector2(4, 4));
          particle.updateForces(0.5);

          expect(particle.velocity, closeToVector(Vector2(8, 8)));
        },
      );
    });

    group('solveConstraints', () {
      flameGame.test('solve constraints', (game) async {
        final solver = _TestSolver(subStep: 1);
        await game.ensureAdd(solver);

        final particle1 = _TestParticle(position: Vector2.zero());
        final particle2 = _TestParticle(position: Vector2.all(100));
        final constraint = LinkConstraint(
          particle1: particle1,
          particle2: particle2,
          distance: 100,
        );

        await solver.ensureAdd(particle1);
        await solver.ensureAdd(particle2);
        await solver.ensureAdd(constraint);

        solver.solveConstraints();

        expect(particle1.position, closeToVector(Vector2.all(14.644), 0.001));
        expect(particle2.position, closeToVector(Vector2.all(85.355), 0.001));
        expect(constraint.isValid, isTrue);
      });
    });

    group('removeBrokenConstraints', () {
      flameGame.test('removes broken constraints', (game) async {
        final solver = _TestSolver(subStep: 1);
        await game.ensureAdd(solver);

        final particle1 = _TestParticle(position: Vector2.zero());
        final particle2 = _TestParticle(position: Vector2.all(200));
        final constraint = LinkConstraint(
          particle1: particle1,
          particle2: particle2,
          distance: 100,
        );

        await solver.ensureAdd(particle1);
        await solver.ensureAdd(constraint);

        expect(solver.constraints, contains(constraint));

        solver.removeBrokenConstraints();
        await game.ready();

        expect(solver.constraints, isEmpty);
      });
    });
  });
}

// ignore_for_file: prefer_const_constructors, cascade_invocations
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physik/physik.dart';

class _TestParticle extends PositionComponent with Particle {
  _TestParticle({super.position});
}

void main() {
  group('LinkConstraint', () {
    group('solve', () {
      flameGame.test('skips solving if constraint is not valid', (game) async {
        final particle1 = _TestParticle(position: Vector2.zero());
        final particle2 = _TestParticle(position: Vector2.all(100));
        final constraint = LinkConstraint(
          particle1: particle1,
          particle2: particle2,
          distance: 100,
        );

        await game.ensureAdd(particle1);
        await game.ensureAdd(constraint);

        constraint.solve();

        expect(particle1.position, closeToVector(Vector2.zero()));
        expect(particle2.position, closeToVector(Vector2.all(100)));
      });

      flameGame.test('solving the constraint if it is valid', (game) async {
        final particle1 = _TestParticle(position: Vector2.zero());
        final particle2 = _TestParticle(position: Vector2.all(100));
        final constraint = LinkConstraint(
          particle1: particle1,
          particle2: particle2,
          distance: 100,
        );

        await game.ensureAdd(particle1);
        await game.ensureAdd(particle2);
        await game.ensureAdd(constraint);

        constraint.solve();

        expect(particle1.position, closeToVector(Vector2.all(14.644), 0.001));
        expect(particle2.position, closeToVector(Vector2.all(85.355), 0.001));
        expect(constraint.isValid, isTrue);
      });

      flameGame.test(
        'solving the constraint but only move particle 1',
        (game) async {
          final particle1 = _TestParticle(position: Vector2.zero());
          final particle2 = _TestParticle(position: Vector2.all(100))
            ..isMoving = false;
          final constraint = LinkConstraint(
            particle1: particle1,
            particle2: particle2,
            distance: 100,
          );

          await game.ensureAdd(particle1);
          await game.ensureAdd(particle2);
          await game.ensureAdd(constraint);

          constraint.solve();

          expect(particle1.position, closeToVector(Vector2.all(14.644), 0.001));
          expect(particle2.position, closeToVector(Vector2.all(100)));
          expect(constraint.isValid, isTrue);
        },
      );

      flameGame.test(
        'solving the constraint but only move particle 2',
        (game) async {
          final particle1 = _TestParticle(position: Vector2.zero())
            ..isMoving = false;
          final particle2 = _TestParticle(position: Vector2.all(100));
          final constraint = LinkConstraint(
            particle1: particle1,
            particle2: particle2,
            distance: 100,
          );

          await game.ensureAdd(particle1);
          await game.ensureAdd(particle2);
          await game.ensureAdd(constraint);

          constraint.solve();

          expect(particle1.position, closeToVector(Vector2.zero()));
          expect(particle2.position, closeToVector(Vector2.all(85.355), 0.001));
          expect(constraint.isValid, isTrue);
        },
      );

      flameGame.test('solving the constraint and break it', (game) async {
        final particle1 = _TestParticle(position: Vector2.zero());
        final particle2 = _TestParticle(position: Vector2.all(200));
        final constraint = LinkConstraint(
          particle1: particle1,
          particle2: particle2,
          distance: 100,
        );

        await game.ensureAdd(particle1);
        await game.ensureAdd(particle2);
        await game.ensureAdd(constraint);

        constraint.solve();

        expect(particle1.position, closeToVector(Vector2.all(64.644), 0.001));
        expect(particle2.position, closeToVector(Vector2.all(135.355), 0.001));
        expect(constraint.isValid, isFalse);
      });
    });

    group('isValid', () {
      flameGame.test(
        'returns false if one of the particles is not mounted',
        (game) async {
          final particle1 = _TestParticle(position: Vector2.zero());
          final particle2 = _TestParticle(position: Vector2.all(100));
          final constraint = LinkConstraint(
            particle1: particle1,
            particle2: particle2,
            distance: 142,
          );

          await game.ensureAdd(particle1);
          await game.ensureAdd(constraint);

          expect(constraint.isValid, false);
        },
      );

      flameGame.test('returns false if the constraint is broken', (game) async {
        final particle1 = _TestParticle(position: Vector2.zero());
        final particle2 = _TestParticle(position: Vector2.all(100));
        final constraint = LinkConstraint(
          particle1: particle1,
          particle2: particle2,
          distance: 100,
          maxElongationRatio: 0.5,
        );

        await game.ensureAdd(particle1);
        await game.ensureAdd(particle2);
        await game.ensureAdd(constraint);

        constraint.solve();

        expect(constraint.isValid, false);
      });

      flameGame.test(
        '''returns true if both particles are mounted and the constraint is not broken''',
        (game) async {
          final particle1 = _TestParticle(position: Vector2.zero());
          final particle2 = _TestParticle(position: Vector2.all(100));
          final constraint = LinkConstraint(
            particle1: particle1,
            particle2: particle2,
            distance: 142,
          );

          await game.ensureAdd(particle1);
          await game.ensureAdd(particle2);
          await game.ensureAdd(constraint);

          expect(constraint.isValid, true);
        },
      );
    });

    flameGame.testGameWidget(
      'renders debug line between two particles',
      setUp: (game, tester) async {
        final particle1 = _TestParticle(position: Vector2.zero());
        final particle2 = _TestParticle(position: Vector2.all(100));
        final constraint = LinkConstraint(
          particle1: particle1,
          particle2: particle2,
          distance: 142,
        )..debugMode = true;

        game.camera.followVector2(Vector2.all(50));

        await game.ensureAdd(particle1);
        await game.ensureAdd(particle2);
        await game.ensureAdd(constraint);
      },
      verify: (game, tester) async {
        await expectLater(
          find.byGame(),
          matchesGoldenFile('golden/link_constraint_debug.png'),
        );
      },
    );
  });
}

// ignore_for_file: prefer_const_constructors, cascade_invocations
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physik/physik.dart';

class _TestParticle extends PositionComponent with Particle {
  _TestParticle({super.position});
}

void main() {
  group('Particle', () {
    flameGame.test('sets the old position to position onLoad', (game) async {
      final particle = _TestParticle(position: Vector2(1, 2));

      await game.ensureAdd(particle);

      expect(particle.oldPosition, equals(Vector2(1, 2)));
    });

    group('updatePosition', () {
      flameGame.test('updates the old position with the current', (game) async {
        final particle = _TestParticle(position: Vector2.zero());
        await game.ensureAdd(particle);

        expect(particle.oldPosition, equals(Vector2.zero()));

        particle.position.setFrom(Vector2(4, 4));
        particle.updatePosition(0.5);

        expect(particle.oldPosition, equals(Vector2(4, 4)));
      });

      flameGame.test(
        'updates the velocity and position based on applied forces',
        (game) async {
          final particle = _TestParticle(position: Vector2.zero());
          await game.ensureAdd(particle);

          particle.forces.setFrom(Vector2(4, 4));
          particle.updatePosition(0.5);

          expect(particle.velocity, closeToVector(Vector2(2, 2)));
          expect(particle.position, closeToVector(Vector2(1, 1)));
        },
      );

      flameGame.test(
        'does update the position if moving is false',
        (game) async {
          final particle = _TestParticle(position: Vector2.zero());
          await game.ensureAdd(particle);

          particle.isMoving = false;

          particle.forces.setFrom(Vector2(4, 4));
          particle.updatePosition(0.5);

          expect(particle.velocity, closeToVector(Vector2.zero()));
          expect(particle.position, closeToVector(Vector2.zero()));
        },
      );
    });

    group('updateForces', () {
      flameGame.test('recalculates velocity based on positions', (game) async {
        final particle = _TestParticle(position: Vector2.zero());
        await game.ensureAdd(particle);

        particle.position.setFrom(Vector2(4, 4));
        particle.updateForces(0.5);

        expect(particle.velocity, closeToVector(Vector2(8, 8)));
      });

      flameGame.test('resets forces back to zero', (game) async {
        final particle = _TestParticle(position: Vector2.zero());
        await game.ensureAdd(particle);

        particle.forces.setFrom(Vector2(4, 4));
        particle.updateForces(0.5);

        expect(particle.forces, closeToVector(Vector2.zero()));
      });
    });
  });
}
